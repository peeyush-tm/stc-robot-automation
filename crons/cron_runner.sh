#!/bin/bash
# ──────────────────────────────────────────────────────────────
# cron_runner.sh — Full regression run for STC CMP Automation.
#
# Cron line (runs daily at 2 AM IST = 8:30 PM UTC prev day):
#   30 20 * * * /opt/Automation/STC/crons/cron_runner.sh >> /opt/Automation/STC/logs/cron.log 2>&1
#
# What it does:
#   1. Activates virtualenv
#   2. Pulls latest code (git pull)
#   3. Runs all tasks.csv suites via run_tests.sh
#   4. Sends email report
# ──────────────────────────────────────────────────────────────
set -uo pipefail

STC_BASE="/opt/Automation/STC"
VENV="${STC_BASE}/venv"
LOGDIR="${STC_BASE}/logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "${LOGDIR}"

export PATH="/usr/local/bin:/usr/bin:/bin:${PATH}"
export DISPLAY=""
export LANG="en_US.UTF-8"
export LD_LIBRARY_PATH="${STC_BASE}/browser/libs/flat:${STC_BASE}/browser/headless-shell:${LD_LIBRARY_PATH:-}"

echo ""
echo "============================================================"
echo "CRON FULL RUN: ${TIMESTAMP}"
echo "============================================================"

if [ ! -f "${VENV}/bin/activate" ]; then
    echo "ERROR: virtualenv not found at ${VENV}. Run setup first."
    exit 1
fi
source "${VENV}/bin/activate"
cd "${STC_BASE}"

# Pull latest code (non-fatal)
echo "[${TIMESTAMP}] Pulling latest code..."
git pull origin master 2>&1 || echo "WARNING: git pull failed — running with existing code."

# Run all suites with email
echo "[${TIMESTAMP}] Starting full regression run..."
./run_tests.sh --env qe --email 2>&1

EXIT_CODE=$?
echo "[$(date +"%Y-%m-%d_%H-%M-%S")] Cron full run complete. Exit code: ${EXIT_CODE}"
exit ${EXIT_CODE}
