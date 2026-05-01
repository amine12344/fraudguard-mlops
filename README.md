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

M1 — Repository Bootstrap + First CI

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
