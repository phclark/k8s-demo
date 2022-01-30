from fastapi.testclient import TestClient

from src.main import app

client = TestClient(app)


def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert 'X-VERSION' in response.headers
    assert response.json() == {
        "message": "Automate all the things!",
        "timestamp": 1529729125
    }
