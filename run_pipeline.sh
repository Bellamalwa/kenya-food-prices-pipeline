#!/bin/bash
# run_pipeline.sh — wraps `make pipeline` with logging.

set -e

LOG_DIR="logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/pipeline_$(date +%Y%m%d_%H%M%S).log"

{
  echo "[$(date -Iseconds)] Pipeline started"
  echo "---"
} | tee "$LOG_FILE"

if make pipeline 2>&1 | tee -a "$LOG_FILE"; then
  echo "---" | tee -a "$LOG_FILE"
  echo "[$(date -Iseconds)] Pipeline SUCCEEDED" | tee -a "$LOG_FILE"
  exit 0
else
  echo "---" | tee -a "$LOG_FILE"
  echo "[$(date -Iseconds)] Pipeline FAILED (exit code $?)" | tee -a "$LOG_FILE"
  exit 1
fi
