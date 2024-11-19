from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_secure_endpoint_unauthorized():
    response = client.get("/secure-endpoint")
    assert response.status_code == 401

def test_error_handling():
    response = client.get("/nonexistent-endpoint")
    assert response.status_code == 404
