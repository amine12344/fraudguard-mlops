from fastapi.testclient import TestClient

from products.fraudguard.inference.app import main


class DummyModelLoader:
    def is_ready(self) -> bool:
        return True

    def predict_probability(self, dataframe) -> float:
        return 0.73


def test_metrics_endpoint_exists(monkeypatch):
    monkeypatch.setattr(main, "model_loader", DummyModelLoader())

    client = TestClient(main.app)

    prediction_response = client.post(
        "/predict",
        json={
            "TransactionAmt": 129.99,
            "ProductCD": "W",
            "card1": 12345,
            "card2": 321,
            "card3": 150,
            "card4": "visa",
            "card5": 226,
            "card6": "credit",
            "addr1": 204,
            "addr2": 87,
            "P_emaildomain": "gmail.com",
            "R_emaildomain": "gmail.com",
            "DeviceType": "desktop",
            "DeviceInfo": "Windows",
        },
    )

    assert prediction_response.status_code == 200

    metrics_response = client.get("/metrics")

    assert metrics_response.status_code == 200
    assert "fraudguard_requests_total" in metrics_response.text
    assert "fraudguard_predictions_total" in metrics_response.text
