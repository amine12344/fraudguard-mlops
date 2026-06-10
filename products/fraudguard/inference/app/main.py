import os
from time import perf_counter

from fastapi import FastAPI, HTTPException
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest
from starlette.responses import Response

from products.fraudguard.inference.app.features import request_to_dataframe
from products.fraudguard.inference.app.model_loader import ModelLoader
from products.fraudguard.inference.app.schemas import PredictionRequest, PredictionResponse
from products.fraudguard.inference.app.telemetry import (
    PREDICTION_COUNT,
    PREDICTION_LATENCY,
    PREDICTION_SCORE,
    REQUEST_COUNT,
)

MODEL_THRESHOLD = float(os.getenv("MODEL_THRESHOLD", "0.5"))
MODEL_VERSION = os.getenv("MODEL_VERSION", "local")

app = FastAPI(
    title="FraudGuard Inference API",
    version="0.1.0",
    description="Real-time fraud detection inference service.",
)

model_loader = ModelLoader()


@app.on_event("startup")
def startup() -> None:
    model_loader.load()


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/metrics")
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/ready")
def ready() -> dict:
    return {"ready": model_loader.is_ready()}


@app.post("/predict", response_model=PredictionResponse)
def predict(request: PredictionRequest) -> PredictionResponse:
    start_time = perf_counter()

    if not model_loader.is_ready():
        REQUEST_COUNT.labels(endpoint="/predict", method="POST", status="503").inc()
        raise HTTPException(status_code=503, detail="Model is not ready.")

    dataframe = request_to_dataframe(request)
    probability = model_loader.predict_probability(dataframe)
    decision = "review" if probability >= MODEL_THRESHOLD else "approve"

    PREDICTION_LATENCY.observe(perf_counter() - start_time)
    PREDICTION_COUNT.labels(decision=decision).inc()
    PREDICTION_SCORE.observe(probability)
    REQUEST_COUNT.labels(endpoint="/predict", method="POST", status="200").inc()

    return PredictionResponse(
        fraud_probability=probability,
        decision=decision,
        threshold=MODEL_THRESHOLD,
        model_version=MODEL_VERSION,
    )
