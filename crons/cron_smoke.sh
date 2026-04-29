#!/bin/bash
# ──────────────────────────────────────────────────────────────
# cron_smoke.sh — Daily Smoke Test (Mon-Fri)
#
# Cron: 30 3 * * 1-5 /opt/Automation/STC/crons/cron_smoke.sh >> /opt/Automation/STC/logs/cron_smoke.log 2>&1
# (9 AM IST = 3:30 AM UTC)
# ──────────────────────────────────────────────────────────────
set -uo pipefail

STC_BASE="/opt/Automation/STC"
VENV="${STC_BASE}/venv"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Check CRON_ENABLED flag in .env
CRON_ENABLED=$(grep -E "^CRON_ENABLED=" "${STC_BASE}/.env" 2>/dev/null | cut -d'=' -f2 | tr -d ' ')
if [ "${CRON_ENABLED}" != "true" ]; then
    echo "[${TIMESTAMP}] CRON_ENABLED is not true. Skipping smoke cron."
    exit 0
fi

export PATH="/usr/local/bin:/usr/bin:/bin:${PATH}"
export DISPLAY=""
export LANG="en_US.UTF-8"
export LD_LIBRARY_PATH="${STC_BASE}/browser/libs/flat:${STC_BASE}/browser/headless-shell:${LD_LIBRARY_PATH:-}"

echo ""
echo "============================================================"
echo "SMOKE CRON: ${TIMESTAMP}"
echo "============================================================"

source "${VENV}/bin/activate"
cd "${STC_BASE}"

./run_tests.sh \
    --suite Login \
    --suite Sanity \
    --env qe \
    --browser headlesschrome \
    --email \
    2>&1

echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Smoke cron complete."
