#!/usr/bin/env bash
set -euo pipefail

VENV="${VENV:-.venv}"
PYTHON="${PYTHON:-}"
PY_LAUNCHER_ARGS=()

OS="$(uname -s 2>/dev/null || echo unknown)"
OS_FAMILY="linux"
case "$OS" in
  Darwin*) OS_FAMILY="mac";;
  Linux*) OS_FAMILY="linux";;
  MINGW*|MSYS*|CYGWIN*) OS_FAMILY="windows";;
  *) OS_FAMILY="linux";;
esac

venv_python_path() {
  if [[ "$OS_FAMILY" == "windows" ]]; then
    echo "$VENV/Scripts/python.exe"
  else
    echo "$VENV/bin/python"
  fi
}

python_exists() {
  local p="$1"
  if [[ "$OS_FAMILY" == "windows" ]]; then
    [[ -f "$p" ]]
  else
    [[ -x "$p" ]]
  fi
}

if [[ -z "$PYTHON" ]]; then
  PYTHON="$(venv_python_path)"
fi

if ! python_exists "$PYTHON"; then
  if [[ "$OS_FAMILY" == "windows" ]] && command -v py >/dev/null 2>&1; then
    PYTHON="py"
    PY_LAUNCHER_ARGS=(-3)
  fi
fi

if [[ "$PYTHON" != "py" ]] && ! python_exists "$PYTHON"; then
  echo "Error: Python not found at $PYTHON"
  echo "Tip: run ./install.sh first or set PYTHON to your interpreter."
  exit 1
fi

exec "$PYTHON" "${PY_LAUNCHER_ARGS[@]}" -m src.tracewave
