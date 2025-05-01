#!/usr/bin/env bash
set -euo pipefail

echo "🔁 Printing current Git branch every 3 seconds..."
echo "Press Ctrl+C to stop."
echo ""

while true; do
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "❌ Not in a Git repo")
  echo "⏰ $(date '+%H:%M:%S') → Branch: $branch"
  sleep 3
done
