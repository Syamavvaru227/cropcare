import base64
import hashlib
import hmac
import io
import json
import os
import re
import secrets
import time
import uuid
import warnings
from contextlib import asynccontextmanager
from datetime import datetime, timezone
from pathlib import Path
from threading import Lock

from fastapi import FastAPI, Depends, File, HTTPException, UploadFile, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi.staticfiles import StaticFiles
from PIL import Image, ImageOps, UnidentifiedImageError
from pydantic import BaseModel, Field
from sqlalchemy import select, or_, delete
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session
from starlette.concurrency import run_in_threadpool
from .database import Base, engine, db_session, User, Token, Scan
from .inference import Predictor

DISEASES = json.loads((Path(__file__).parent / 'data/diseases.json').read_text(encoding='utf-8'))
predictor = Predictor()
inference_lock = Lock()
Image.MAX_IMAGE_PIXELS = 16_000_000

@asynccontextmanager
async def lifespan(app):
    Base.metadata.create_all(engine)
    yield

app = FastAPI(title='CropCare API', version='1.0.0', lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=os.getenv('CORS_ORIGINS', 'http://localhost:8080,http://127.0.0.1:8080').split(','), allow_methods=['GET', 'POST', 'DELETE'], allow_headers=['Authorization', 'Content-Type'])
security = HTTPBearer(auto_error=False)

def current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(db_session)):
    if not credentials:
        raise HTTPException(401, 'Sign in to use live mode.')
    token = db.get(Token, hashlib.sha256(credentials.credentials.encode()).hexdigest())
    if not token or token.expires < time.time():
        raise HTTPException(401, 'Session expired. Sign in again.')
    user = db.get(User, token.user_id)
    if not user:
        raise HTTPException(401, 'Invalid session.')
    return user

def password_hash(password, salt=None):
    salt = salt or secrets.token_hex(16)
    digest = hashlib.pbkdf2_hmac('sha256', password.encode(), salt.encode(), 600_000).hex()
    return salt + ':' + digest

def profile(user):
    return {'id': user.id, 'name': user.name, 'mobile': user.mobile, 'email': user.email}

def session_response(user, db):
    raw = secrets.token_urlsafe(48)
    db.execute(delete(Token).where(Token.expires < int(time.time())))
    db.add(Token(digest=hashlib.sha256(raw.encode()).hexdigest(), user_id=user.id, expires=int(time.time()) + 86400))
    db.commit()
    return {'token': raw, 'user': profile(user), 'expires_in': 86400}

class Registration(BaseModel):
    name: str = Field(min_length=1, max_length=80)
    mobile: str = Field(pattern=r'^\+?[0-9]{10,15}$')
    email: str | None = Field(default=None, max_length=254)
    password: str = Field(min_length=10, max_length=128)

class Login(BaseModel):
    identifier: str = Field(min_length=1, max_length=254)
    password: str = Field(min_length=1, max_length=128)

# In-memory abuse control; deploy one worker or put a distributed limiter at the proxy.
attempts = {}
rate_lock = Lock()
def auth_limit(request: Request):
    key = request.client.host if request.client else 'unknown'
    now = time.monotonic()
    with rate_lock:
        for stale in [k for k, v in attempts.items() if now - v[0] > 60]:
            del attempts[stale]
        start, count = attempts.get(key, (now, 0))
        if count >= 12:
            raise HTTPException(429, 'Too many attempts. Wait one minute.')
        attempts[key] = (start, count + 1)

@app.get('/health')
def health():
    return {'status': 'ok', 'live_inference': predictor.model is not None, 'reason': predictor.reason}

@app.get('/api/diseases')
def diseases():
    return DISEASES

@app.post('/api/auth/register', dependencies=[Depends(auth_limit)])
def register(body: Registration, db: Session = Depends(db_session)):
    email = body.email.strip().lower() if body.email else None
    if email and not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', email):
        raise HTTPException(422, 'Enter a valid email address.')
    if not body.name.strip():
        raise HTTPException(422, 'Name is required.')
    user = User(id=str(uuid.uuid4()), name=body.name.strip(), mobile=body.mobile, email=email, password=password_hash(body.password))
    db.add(user)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(409, 'Account could not be created with these details.')
    return session_response(user, db)

@app.post('/api/auth/login', dependencies=[Depends(auth_limit)])
def login(body: Login, db: Session = Depends(db_session)):
    user = db.scalar(select(User).where(or_(User.mobile == body.identifier.strip(), User.email == body.identifier.strip().lower())))
    stored = user.password if user else password_hash('unused-dummy-password', '0' * 32)
    valid = hmac.compare_digest(stored, password_hash(body.password, stored.split(':')[0]))
    if not user or not valid:
        raise HTTPException(401, 'Incorrect login details.')
    return session_response(user, db)

@app.get('/api/me')
def me(user: User = Depends(current_user)):
    return profile(user)

@app.post('/api/auth/logout')
def logout(credentials: HTTPAuthorizationCredentials = Depends(security), user: User = Depends(current_user), db: Session = Depends(db_session)):
    db.execute(delete(Token).where(Token.digest == hashlib.sha256(credentials.credentials.encode()).hexdigest()))
    db.commit()
    return {'ok': True}

def decode_image(raw):
    try:
        with warnings.catch_warnings():
            warnings.simplefilter('error', Image.DecompressionBombWarning)
            with Image.open(io.BytesIO(raw)) as original:
                if original.format not in ['JPEG', 'PNG', 'WEBP']:
                    raise ValueError()
                original.load()
                if min(original.size) < 64:
                    raise ValueError()
                return ImageOps.exif_transpose(original).convert('RGB')
    except (UnidentifiedImageError, OSError, ValueError, Image.DecompressionBombError, Image.DecompressionBombWarning):
        raise HTTPException(422, 'Use a valid JPEG, PNG or WebP image, at least 64 pixels wide and high, under 16 megapixels.')

def analyze(raw):
    image = decode_image(raw)
    if predictor.model is None:
        raise HTTPException(503, predictor.reason)
    with inference_lock:
        disease, confidence = predictor.predict(image)
    image.thumbnail((768, 768))
    out = io.BytesIO()
    image.save(out, 'JPEG', quality=80)
    return disease, confidence, out.getvalue()

@app.post('/api/scans', status_code=201)
async def scan(file: UploadFile = File(...), user: User = Depends(current_user), db: Session = Depends(db_session)):
    raw = await file.read(8 * 1024 * 1024 + 1)
    await file.close()
    if len(raw) > 8 * 1024 * 1024:
        raise HTTPException(413, 'Image must be smaller than 8 MB.')
    disease, confidence, image = await run_in_threadpool(analyze, raw)
    result = {'id': str(uuid.uuid4()), 'disease_id': disease, 'confidence': confidence, 'demo': False, 'created_at': datetime.now(timezone.utc).isoformat(), 'image': base64.b64encode(image).decode()}
    db.add(Scan(id=result['id'], user_id=user.id, result=json.dumps({k: v for k, v in result.items() if k != 'image'}), image=image))
    db.commit()
    return result

@app.get('/api/scans')
def history(user: User = Depends(current_user), db: Session = Depends(db_session)):
    rows = db.scalars(select(Scan).where(Scan.user_id == user.id)).all()
    return sorted([{**json.loads(row.result), 'image': base64.b64encode(row.image).decode()} for row in rows], key=lambda x: x['created_at'], reverse=True)

@app.delete('/api/scans/{scan_id}', status_code=204)
def remove_scan(scan_id: str, user: User = Depends(current_user), db: Session = Depends(db_session)):
    row = db.get(Scan, scan_id)
    if not row or row.user_id != user.id:
        raise HTTPException(404, 'Scan not found.')
    db.delete(row)
    db.commit()

# Keep API routes ahead of the web mount. Without STATIC_DIR this remains API-only.
static_dir = os.getenv('STATIC_DIR')
if static_dir:
    app.mount('/', StaticFiles(directory=static_dir, html=True), name='frontend')
