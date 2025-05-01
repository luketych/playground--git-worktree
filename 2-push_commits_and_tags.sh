#!/bin/bash
set -euo pipefail

echo "🚀 Pushing commits..."
git push origin HEAD

echo "🏷️  Pushing tags..."
git push origin --tags

echo "✅ Done."
