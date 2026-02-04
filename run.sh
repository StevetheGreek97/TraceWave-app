#!/usr/bin/env bash
set -euo pipefail

VENV="${VENV:-.venv}"
PYTHON="${PYTHON:-}"

if [[ -z "$PYTHON" ]]; then
  PYTHON="$VENV/bin/python"
fi

if [[ ! -x "$PYTHON" ]]; then
  echo "Error: Python not found at $PYTHON"
  echo "Tip: run ./install.sh first or set PYTHON to your interpreter."
  exit 1
fi

exec "$PYTHON" -m src.tracewave
