#!/usr/bin/env bash
set -euo pipefail

# === Settings ===
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Get the repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_DIR="$REPO_ROOT/../worktrees"
BRANCH_PREFIX="worktree-"

# Validate worktree directory exists
if [ ! -d "$WORKTREE_DIR" ]; then
    echo "✅ No worktree directory found at: $WORKTREE_DIR"
    exit 0
fi

echo "🧹 Cleaning up worktrees from: $WORKTREE_DIR"
echo ""

# === Step 1: Get registered worktrees
registered_worktrees=$(git worktree list --porcelain | awk '/^worktree / {print $2}')

# === Step 2: Remove worktrees that are both registered AND exist
for dir in "$WORKTREE_DIR"/*; do
  [[ -d "$dir" ]] || continue

  if echo "$registered_worktrees" | grep -Fxq "$dir"; then
    echo "📂 Removing registered worktree: $dir"
    git worktree remove --force "$dir"
  else
    echo "⚠️  Skipping $dir — not registered as a worktree"
  fi
done

# === Step 3: Prune stale worktree metadata
echo ""
echo "🧹 Pruning stale Git worktree metadata..."
git worktree prune

# === Step 4: Delete branches that start with 'worktree-'
echo ""
echo "🧨 Deleting branches that start with '$BRANCH_PREFIX'..."

for branch in $(git branch --format='%(refname:short)' | grep "^$BRANCH_PREFIX" || true); do
  echo "❌ Deleting branch: $branch"
  git branch -D "$branch"
done

# === Step 5: Remove empty worktree root directory
if [ -d "$WORKTREE_DIR" ] && [ -z "$(ls -A "$WORKTREE_DIR")" ]; then
  rmdir "$WORKTREE_DIR"
  echo "📁 Removed empty $WORKTREE_DIR directory."
fi

echo ""
echo "✅ All valid worktrees and branches cleaned up."
