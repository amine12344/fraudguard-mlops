FROM python:3.11-slim

WORKDIR /app

COPY pyproject.toml ./
COPY products ./products
COPY artifacts ./artifacts

RUN apt-get update \
    && apt-get install -y --no-install-recommends libgomp1 \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --upgrade pip \
    && pip install --no-cache-dir -e .

EXPOSE 8000

CMD ["uvicorn", "products.fraudguard.inference.app.main:app", "--host", "0.0.0.0", "--port", "8000"]