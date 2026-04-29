#!/bin/bash
# ──────────────────────────────────────────────────────────────
# cron_regression.sh — Weekly Full Regression (Sunday night)
#
# Cron: 30 19 * * 0 /opt/Automation/STC/crons/cron_regression.sh >> /opt/Automation/STC/logs/cron_regression.log 2>&1
# (1 AM IST Monday = 7:30 PM UTC Sunday)
# ──────────────────────────────────────────────────────────────
set -uo pipefail

STC_BASE="/opt/Automation/STC"
VENV="${STC_BASE}/venv"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

CRON_ENABLED=$(grep -E "^CRON_ENABLED=" "${STC_BASE}/.env" 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
if [ "${CRON_ENABLED}" != "true" ]; then
    echo "[${TIMESTAMP}] CRON_ENABLED is not true. Skipping regression cron."
    exit 0
fi

export PATH="/usr/local/bin:/usr/bin:/bin:${PATH}"
export DISPLAY=""
export LANG="en_US.UTF-8"
export LD_LIBRARY_PATH="${STC_BASE}/browser/libs/flat:${STC_BASE}/browser/headless-shell:${LD_LIBRARY_PATH:-}"

echo ""
echo "============================================================"
echo "REGRESSION CRON: ${TIMESTAMP}"
echo "============================================================"

source "${VENV}/bin/activate"
cd "${STC_BASE}"

git pull origin master 2>&1 || echo "WARNING: git pull failed."

./run_tests.sh --env qe --email 2>&1

EXIT_CODE=$?
echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Regression cron complete. Exit code: ${EXIT_CODE}"
exit ${EXIT_CODE}
