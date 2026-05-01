.PHONY: install test lint format clean tree

install:
	python -m venv .fgvenv
	. .fgvenv/bin/activate && python -m pip install -U pip
	. .fgvenv/bin/activate && pip install -e .

test:
	. .fgvenv/bin/activate && pytest -q

lint:
	. .fgvenv/bin/activate && ruff check .

format:
	. .fgvenv/bin/activate && ruff format .
	. .fgvenv/bin/activate && ruff check . --fix

clean:
	rm -rf .pytest_cache .ruff_cache
	find . -type d -name "__pycache__" -exec rm -rf {} +

tree:
	find . -maxdepth 4 -type d | sort