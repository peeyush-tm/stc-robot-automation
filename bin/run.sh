#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/setall.sh"
BASE_DIR="${BASE_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# ── Build common args from environment variables ──────────────────────────
PY_ARGS=()
[[ -n "${TESTPLAN:-}" ]] && PY_ARGS+=(--suite "$TESTPLAN")
[[ -n "${PROFILE:-}"  ]] && PY_ARGS+=(--env "$PROFILE")
[[ -n "${BROWSER:-}"  ]] && PY_ARGS+=(--browser "$BROWSER")
[[ -n "${TAGS:-}"     ]] && PY_ARGS+=(--include "$TAGS")

if [[ -n "${RUNNAME:-}" ]]; then
  TIMESTAMP=$(python -c "from datetime import datetime; print(datetime.now().strftime('%Y-%m-%d_%H-%M-%S'))")
  PY_ARGS+=(--outputdir "$BASE_DIR/reports/${RUNNAME}_${TIMESTAMP}")
fi

# ── Framework mode: FRAMEWORK=1 or --framework flag → STCFramework.robot ──
USE_FRAMEWORK=0
[[ "${FRAMEWORK:-}" == "1" ]] && USE_FRAMEWORK=1
if [[ "${1:-}" == "--framework" ]]; then
  USE_FRAMEWORK=1
  shift
fi

if [[ "$USE_FRAMEWORK" == "1" ]]; then
  exec python "$BASE_DIR/run_tests.py" --framework "${PY_ARGS[@]}" "$@"
fi

# ── Default mode: run_tests.py (tasks.csv / specific suite / e2e etc.) ────
if [[ ${#PY_ARGS[@]} -gt 0 ]]; then
  exec python "$BASE_DIR/run_tests.py" "${PY_ARGS[@]}" "$@"
else
  exec python "$BASE_DIR/run_tests.py" "$@"
fi
