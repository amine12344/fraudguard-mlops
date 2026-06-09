from prometheus_client import Counter, Histogram

REQUEST_COUNT = Counter(
    "fraudguard_requests_total",
    "Total number of inference API requests.",
    ["endpoint", "method", "status"],
)

PREDICTION_COUNT = Counter(
    "fraudguard_predictions_total",
    "Total number of predictions by decision.",
    ["decision"],
)

PREDICTION_LATENCY = Histogram(
    "fraudguard_prediction_latency_seconds",
    "Prediction latency in seconds.",
)

PREDICTION_SCORE = Histogram(
    "fraudguard_prediction_score",
    "Fraud probability score distribution.",
    buckets=(0.0, 0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 1.0),
)
