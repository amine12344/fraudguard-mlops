# FraudGuard MLOps Platform

FraudGuard is a local-first production-grade MLOps platform for real-time fraud detection.

## Goal

Build an end-to-end MLOps system using:

- IEEE-CIS Fraud Detection dataset
- Python
- FastAPI
- LightGBM
- MLflow
- Feast
- Redpanda/Kafka
- Docker
- kind Kubernetes
- Prometheus/Grafana
- Kubeflow Pipelines
- Argo CD
- Argo Rollouts
- GitHub Actions
- Security scans and reports

## Current Milestone

M1 — Repository Bootstrap + First CI + Data Ingestion Pipeline

## Local Setup

```bash
sudo apt update
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl git \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
libffi-dev liblzma-dev
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc
exec "$SHELL"
pyenv install 3.12.8
pyenv global 3.12.8
pyenv install --list | grep -E " 3\.(12|13)\."
```

```bash
make install
make lint
make test
```

## Data Ingestion and Validation

### Prerequisites

Download the IEEE-CIS Fraud Detection dataset from Kaggle and place the files in `data/raw/`:

```text
data/raw/train_transaction.csv
data/raw/train_identity.csv
data/raw/test_transaction.csv
data/raw/test_identity.csv
```

### Data Operations

Create a sample dataset from the raw IEEE-CIS data:

```bash
make data-sample
```

Create a synthetic sample for testing (no raw data required):

```bash
make data-synthetic
```

Validate data quality and schema:

```bash
make data-check    # Basic validation
make data-validate # Pandera schema validation
```

### Data Validation Reports

Validation reports are generated in `reports/data/`:

- `sample_validation.json`: Basic data quality metrics
- `validation_report.json`: Pandera schema validation results

### CI/CD

The GitHub Actions workflow includes automated data validation:

- **lint-and-test**: Code quality checks and unit tests
- **validate-synthetic-data**: End-to-end data pipeline validation using synthetic data

Reports are uploaded as artifacts and summarized in the job output.
