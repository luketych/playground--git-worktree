#!/usr/bin/env bash
set -euo pipefail

TAG_PATTERN='^(playable-|working-)'
WORKTREE_ROOT="../worktrees"

echo "📁 Creating worktrees in: $WORKTREE_ROOT"
mkdir -p "$WORKTREE_ROOT"

# List tags matching playable-* or working-*
matching_tags=$(git tag | grep -E "$TAG_PATTERN" || true)

if [[ -z "$matching_tags" ]]; then
  echo "❌ No matching tags found. (Expected tags starting with 'playable-' or 'working-')"
  exit 1
fi

for tag in $matching_tags; do
  worktree_folder="$WORKTREE_ROOT/$tag"
  branch_name="worktree-$tag"

  # Skip if folder already exists
  if [[ -d "$worktree_folder" ]]; then
    echo "⚠️  Skipping $tag → $worktree_folder already exists."
    continue
  fi

  echo "🌱 Creating worktree for tag: $tag → branch: $branch_name"

  # Create branch from tag
  git branch "$branch_name" "$tag"

  # Add worktree
  git worktree add "$worktree_folder" "$branch_name"

  echo "✅ Created: $worktree_folder → $branch_name"
done

echo ""
echo "🏁 All matching tags processed."
