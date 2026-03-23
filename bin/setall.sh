#!/usr/bin/env bash
# Set project base and env for STC Automation (source before run.sh or run_tests.py)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
export BASE_DIR
export PYTHONPATH="$BASE_DIR:$BASE_DIR/variables:$BASE_DIR/variables/common:${PYTHONPATH:-}"
if [ -f "$BASE_DIR/venv/bin/activate" ]; then
  . "$BASE_DIR/venv/bin/activate"
elif [ -f "$BASE_DIR/.venv/bin/activate" ]; then
  . "$BASE_DIR/.venv/bin/activate"
fi
