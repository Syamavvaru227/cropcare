import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


class StaticHostingTests(unittest.TestCase):
    def test_frontend_and_api_share_a_host_without_shadowing_routes(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            web = root / 'web'
            web.mkdir()
            (web / 'index.html').write_text('<html>CropCare Render</html>', encoding='utf-8')
            (web / 'main.dart.js').write_text('// compiled app', encoding='utf-8')
            env = dict(os.environ, STATIC_DIR=str(web), DATABASE_URL='sqlite:///' + str(root / 'test.db'))
            script = '''
from fastapi.testclient import TestClient
from app.main import app
from app.database import engine
with TestClient(app) as client:
    assert client.get('/').text == '<html>CropCare Render</html>'
    assert client.get('/main.dart.js').status_code == 200
    assert client.get('/health').json()['status'] == 'ok'
    assert len(client.get('/api/diseases').json()) == 10
    assert client.get('/api/scans').status_code == 401
    assert client.get('/api/missing').status_code == 404
    assert client.get('/.env').status_code == 404
engine.dispose()
'''
            result = subprocess.run([sys.executable, '-c', script], env=env, capture_output=True, text=True, timeout=45)
            self.assertEqual(result.returncode, 0, result.stderr)
