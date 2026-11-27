import os
from sqlalchemy import create_engine, ForeignKey, String, Text, LargeBinary
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, sessionmaker

DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///./cropcare.db')
engine = create_engine(DATABASE_URL, connect_args={'check_same_thread': False} if DATABASE_URL.startswith('sqlite') else {}, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine)

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = 'users'
    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    name: Mapped[str] = mapped_column(String(80))
    mobile: Mapped[str] = mapped_column(String(15), unique=True)
    email: Mapped[str | None] = mapped_column(String(254), unique=True, nullable=True)
    password: Mapped[str] = mapped_column(String(256))

class Token(Base):
    __tablename__ = 'tokens'
    digest: Mapped[str] = mapped_column(String(64), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey('users.id'))
    expires: Mapped[int]

class Scan(Base):
    __tablename__ = 'scans'
    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(ForeignKey('users.id'), index=True)
    result: Mapped[str] = mapped_column(Text)
    image: Mapped[bytes] = mapped_column(LargeBinary(length=2**24))

def db_session():
    with SessionLocal() as db:
        yield db
