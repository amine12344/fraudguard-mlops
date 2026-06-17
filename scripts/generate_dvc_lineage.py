import json
import subprocess
from pathlib import Path

import yaml

OUTPUT_PATH = Path("reports/dvc/lineage.md")


def run_command(command: list[str]) -> str:
    result = subprocess.run(
        command,
        check=False,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip() or result.stderr.strip()


def load_yaml(path: Path) -> dict:
    if not path.exists():
        return {}
    return yaml.safe_load(path.read_text(encoding="utf-8")) or {}


def load_json(path: Path) -> dict:
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    params = load_yaml(Path("params.yaml"))
    metrics = load_json(Path("reports/model/metrics.json"))

    dag = run_command(["dvc", "dag"])
    status = run_command(["dvc", "status"])

    content = f"""# FraudGuard DVC Lineage Report

## Purpose

This report documents the reproducible DVC pipeline for FraudGuard.

## Project Parameters

```yaml
{yaml.safe_dump(params)}
```

## Model Metrics

```json
{json.dumps(metrics, indent=2)}
```

## Pipeline DAG

```text
{dag}
```

## DVC Status

```text
{status}
```
"""

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(content, encoding="utf-8")

    print(f"Created DVC lineage report: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
