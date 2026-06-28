import pytest
from flask.testing import FlaskClient

from app.server import app


@pytest.fixture()
def client() -> FlaskClient:
    app.config["TESTING"] = True
    with app.test_client() as c:
        return c


def test_index_returns_ok(client: FlaskClient) -> None:
    response = client.get("/")
    assert response.status_code == 200
    assert response.get_json() == {"message": "hello", "status": "ok"}


def test_health_returns_healthy(client: FlaskClient) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy"}
