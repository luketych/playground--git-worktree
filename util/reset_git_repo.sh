#!/usr/bin/env bash
set -euo pipefail

# GitHub repo SSH URL (correct format)
REMOTE_URL="git@github.com-luketych:luketych/playground--git-worktree.git"
DEFAULT_BRANCH="main"

echo "⚠️  WARNING: This will erase all Git history and tags, and force-push to:"
echo "   $REMOTE_URL"
read -rp "Are you sure? Type 'yes' to continue: " confirm

if [[ "$confirm" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi


echo "🧹 Reinitializing Git repo..."
git init
git add .
git commit -m "Initial commit after full reset"

echo "🔗 Setting remote..."
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE_URL"

echo "🚀 Force pushing to $DEFAULT_BRANCH..."
git branch -M "$DEFAULT_BRANCH"
git push -f origin "$DEFAULT_BRANCH"

echo "❌ Deleting remote tags..."
# Fetch remote tags first
git fetch --tags
for tag in $(git tag); do
  git tag -d "$tag"                    # delete local tag
  git push origin ":refs/tags/$tag"   # delete remote tag
done

echo "✅ History and tags wiped. Repo reset and pushed successfully."
