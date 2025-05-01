#!/usr/bin/env bash
set -euo pipefail

# === Settings ===
WORKTREE_DIR="../worktrees"
BRANCH_PREFIX="worktree-"

echo "🧹 Cleaning up worktrees from: $WORKTREE_DIR"
echo ""

# === Step 1: Remove worktree folders and unregister them ===
for dir in "$WORKTREE_DIR"/*; do
  [[ -d "$dir" ]] || continue
  echo "📂 Removing worktree: $dir"
  git worktree remove --force "$dir"
done

# === Step 2: Delete branches starting with 'worktree-' ===
echo ""
echo "🧨 Deleting branches that start with '$BRANCH_PREFIX'..."

for branch in $(git branch --format='%(refname:short)' | grep "^$BRANCH_PREFIX"); do
  echo "❌ Deleting branch: $branch"
  git branch -D "$branch"
done

# Optional: Remove empty worktree folder
if [ -d "$WORKTREE_DIR" ] && [ -z "$(ls -A "$WORKTREE_DIR")" ]; then
  rmdir "$WORKTREE_DIR"
  echo "📁 Removed empty $WORKTREE_DIR directory."
fi

echo ""
echo "✅ All worktrees and worktree branches cleaned up."
