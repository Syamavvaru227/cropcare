import io
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

tmp = tempfile.TemporaryDirectory()
os.environ['DATABASE_URL'] = 'sqlite:///' + str(Path(tmp.name) / 'test.db')
from fastapi.testclient import TestClient
from PIL import Image
from app.main import app, attempts, predictor
from app.database import Base, engine

def tearDownModule():
    engine.dispose()
    tmp.cleanup()

class ApiTests(unittest.TestCase):
    def setUp(self):
        Base.metadata.drop_all(engine)
        Base.metadata.create_all(engine)
        attempts.clear()
        self.client = TestClient(app)
        r = self.client.post('/api/auth/register', json={'name': 'Farmer', 'mobile': '9876543210', 'password': 'strong-passphrase'})
        self.assertEqual(r.status_code, 200)
        self.headers = {'Authorization': 'Bearer ' + r.json()['token']}

    def photo(self):
        out = io.BytesIO()
        Image.new('RGB', (224, 224), 'green').save(out, 'JPEG')
        return out.getvalue()

    def test_health_and_library(self):
        self.assertEqual(self.client.get('/health').status_code, 200)
        self.assertEqual(len(self.client.get('/api/diseases').json()), 10)

    def test_private_history_and_logout(self):
        self.assertEqual(self.client.get('/api/scans').status_code, 401)
        self.assertEqual(self.client.get('/api/scans', headers=self.headers).json(), [])
        self.client.post('/api/auth/logout', headers=self.headers)
        self.assertEqual(self.client.get('/api/scans', headers=self.headers).status_code, 401)

    def test_password_login_and_duplicate(self):
        self.assertEqual(self.client.post('/api/auth/login', json={'identifier': '9876543210', 'password': 'wrong'}).status_code, 401)
        self.assertEqual(self.client.post('/api/auth/login', json={'identifier': '9876543210', 'password': 'strong-passphrase'}).status_code, 200)
        self.assertEqual(self.client.post('/api/auth/register', json={'name': 'Other', 'mobile': '9876543210', 'password': 'strong-passphrase'}).status_code, 409)

    def test_invalid_upload_and_missing_model(self):
        self.assertEqual(self.client.post('/api/scans', headers=self.headers, files={'file': ('bad.jpg', b'not an image')}).status_code, 422)
        with patch.object(predictor, 'model', None):
            self.assertEqual(self.client.post('/api/scans', headers=self.headers, files={'file': ('leaf.jpg', self.photo())}).status_code, 503)
        self.assertEqual(self.client.post('/api/scans', headers=self.headers, files={'file': ('large.jpg', b'x' * (8*1024*1024+1))}).status_code, 413)

    def test_owner_isolation_and_image_deletion(self):
        # Mock inference, not validation or persistence. No fake model ships with the app.
        with patch.object(predictor, 'model', object()), patch.object(predictor, 'predict', return_value=('healthy', .9)):
            r = self.client.post('/api/scans', headers=self.headers, files={'file': ('leaf.jpg', self.photo())})
        self.assertEqual(r.status_code, 201)
        scan_id = r.json()['id']
        other = self.client.post('/api/auth/register', json={'name': 'Other', 'mobile': '9876543211', 'password': 'another-password'}).json()
        other_headers = {'Authorization': 'Bearer ' + other['token']}
        self.assertEqual(self.client.get('/api/scans', headers=other_headers).json(), [])
        self.assertEqual(self.client.delete('/api/scans/' + scan_id, headers=other_headers).status_code, 404)
        self.assertEqual(self.client.delete('/api/scans/' + scan_id, headers=self.headers).status_code, 204)
        self.assertEqual(self.client.get('/api/scans', headers=self.headers).json(), [])

    def test_rate_limit(self):
        for _ in range(12):
            self.client.post('/api/auth/login', json={'identifier': 'nobody', 'password': 'wrong'})
        self.assertEqual(self.client.post('/api/auth/login', json={'identifier': 'nobody', 'password': 'wrong'}).status_code, 429)

if __name__ == '__main__':
    unittest.main()
