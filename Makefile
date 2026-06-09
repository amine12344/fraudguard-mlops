.PHONY: install test lint format clean tree

install:
	python -m venv .venv
	. .venv/bin/activate && python -m pip install -U pip
	. .venv/bin/activate && pip install -e .

test:
	. .venv/bin/activate && pytest -q

lint:
	. .venv/bin/activate && ruff check .

format:
	. .venv/bin/activate && ruff format .
	. .venv/bin/activate && ruff check . --fix

clean:
	rm -rf .pytest_cache .ruff_cache
	find . -type d -name "__pycache__" -exec rm -rf {} +

tree:
	find . -maxdepth 4 -type d | sort

.PHONY: data-synthetic data-sample data-check

data-synthetic:
	. .venv/bin/activate && PYTHONPATH=. python scripts/create_synthetic_sample.py

data-sample:
	. .venv/bin/activate && PYTHONPATH=. python scripts/create_sample.py

data-check:
	. .venv/bin/activate && PYTHONPATH=. python scripts/check_data.py

.PHONY: data-validate

data-validate:
	. .venv/bin/activate && PYTHONPATH=. python scripts/validate_data.py

.PHONY: features-build features-check

features-build:
	. .venv/bin/activate && PYTHONPATH=. python products/fraudguard/features/build_features.py

features-check:
	. .venv/bin/activate && PYTHONPATH=. python -c "from products.fraudguard.features.build_features import write_feature_report; write_feature_report()"

.PHONY: train model-check

train:
	. .venv/bin/activate && PYTHONPATH=. python products/fraudguard/training/train.py

model-check:
	. .venv/bin/activate && PYTHONPATH=. python ci/quality-gates/check_metrics.py reports/model/metrics.json

.PHONY: serve smoke

serve:
	. .venv/bin/activate && PYTHONPATH=. uvicorn products.fraudguard.inference.app.main:app --host 0.0.0.0 --port 8000 --reload

smoke:
	bash scripts/smoke_test.sh

.PHONY: platform-up platform-down mlflow-ui mlflow-smoke

platform-up:
	docker compose -f docker-compose.local.yml up -d

platform-down:
	docker compose -f docker-compose.local.yml down

mlflow-ui:
	@echo "MLflow UI: http://localhost:5000"
	@echo "MinIO UI:   http://localhost:9001"

mlflow-smoke:
	. .venv/bin/activate && PYTHONPATH=. MLFLOW_TRACKING_URI=http://localhost:5000 python scripts/mlflow_smoke.py

.PHONY: train-tracking

train-tracking:
	. .venv/bin/activate && \
	PYTHONPATH=. \
	MLFLOW_TRACKING_URI=$${MLFLOW_TRACKING_URI:-http://localhost:5000} \
	MLFLOW_S3_ENDPOINT_URL=$${MLFLOW_S3_ENDPOINT_URL:-http://localhost:9000} \
	AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID:-minio} \
	AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY:-minio123} \
	python products/fraudguard/training/train.py

.PHONY: select-best-run register-model promote-model-dry-run promote-model

select-best-run:
	. .venv/bin/activate && \
	PYTHONPATH=. \
	MLFLOW_TRACKING_URI=$${MLFLOW_TRACKING_URI:-http://localhost:5000} \
	python products/fraudguard/training/select_best_run.py

register-model:
	. .venv/bin/activate && \
	PYTHONPATH=. \
	MLFLOW_TRACKING_URI=$${MLFLOW_TRACKING_URI:-http://localhost:5000} \
	MLFLOW_S3_ENDPOINT_URL=$${MLFLOW_S3_ENDPOINT_URL:-http://localhost:9000} \
	AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID:-minio} \
	AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY:-minio123} \
	MLFLOW_MODEL_NAME=$${MLFLOW_MODEL_NAME:-fraudguard-risk-model} \
	python products/fraudguard/training/register.py

promote-model-dry-run:
	. .venv/bin/activate && \
	PYTHONPATH=. \
	MLFLOW_TRACKING_URI=$${MLFLOW_TRACKING_URI:-http://localhost:5000} \
	MLFLOW_S3_ENDPOINT_URL=$${MLFLOW_S3_ENDPOINT_URL:-http://localhost:9000} \
	AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID:-minio} \
	AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY:-minio123} \
	MLFLOW_MODEL_NAME=$${MLFLOW_MODEL_NAME:-fraudguard-risk-model} \
	PROMOTION_DRY_RUN=true \
	python products/fraudguard/training/promote.py

promote-model:
	. .venv/bin/activate && \
	PYTHONPATH=. \
	MLFLOW_TRACKING_URI=$${MLFLOW_TRACKING_URI:-http://localhost:5000} \
	MLFLOW_S3_ENDPOINT_URL=$${MLFLOW_S3_ENDPOINT_URL:-http://localhost:9000} \
	AWS_ACCESS_KEY_ID=$${AWS_ACCESS_KEY_ID:-minio} \
	AWS_SECRET_ACCESS_KEY=$${AWS_SECRET_ACCESS_KEY:-minio123} \
	MLFLOW_MODEL_NAME=$${MLFLOW_MODEL_NAME:-fraudguard-risk-model} \
	PROMOTION_DRY_RUN=false \
	python products/fraudguard/training/promote.py
.PHONY: docker-build docker-run docker-smoke

docker-build:
	docker build -t fraudguard-inference:local -f products/fraudguard/inference/Dockerfile .
docker-run:
	docker run --rm -p 8000:8000 fraudguard-inference:local
docker-smoke:
	bash scripts/smoke_test.sh

.PHONY: kind-create kind-delete kind-load deploy-dev kind-status kind-port-forward kind-smoke

kind-create:
	kind create cluster --name fraudguard --config infra/kind/kind-config.yaml

kind-delete:
	kind delete cluster --name fraudguard

kind-load:
	kind load docker-image fraudguard-inference:local --name fraudguard

deploy-dev:
	kubectl apply -k infra/k8s/overlays/dev
	kubectl -n fraudguard rollout status deployment/fraudguard-inference --timeout=120s

kind-status:
	kubectl -n fraudguard get all

kind-port-forward:
	kubectl -n fraudguard port-forward svc/fraudguard-inference 8000:8000

kind-smoke:
	bash scripts/smoke_test.sh

.PHONY: deploy-mlflow-kind mlflow-kind-status mlflow-kind-port-forward minio-kind-port-forward

deploy-mlflow-kind:
	kubectl apply -k platform/mlflow/k8s
	kubectl -n mlflow rollout status deployment/postgres --timeout=120s
	kubectl -n mlflow rollout status deployment/minio --timeout=120s
	kubectl -n mlflow rollout status deployment/mlflow --timeout=180s

mlflow-kind-status:
	kubectl -n mlflow get all

mlflow-kind-port-forward:
	kubectl -n mlflow port-forward svc/mlflow 5000:5000

minio-kind-port-forward:
	kubectl -n mlflow port-forward svc/minio 9000:9000