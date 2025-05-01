#!/usr/bin/env bash
set -euo pipefail

# Ensure we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Get the repository root directory
REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_DIR="$REPO_ROOT/../worktrees"
SCRIPT_NAME="${1:-demo_script.sh}"
LOG_OUTPUT=false  # Set to true if you want to log to files instead of console

# Validate that the worktree directory exists
if [ ! -d "$WORKTREE_DIR" ]; then
    echo "❌ Error: Worktree directory not found: $WORKTREE_DIR"
    echo "Run './3-create_worktrees_and_branches_from_tags.sh' first"
    exit 1
fi

# Validate that we have the script to run
if [ ! -f "$REPO_ROOT/$SCRIPT_NAME" ]; then
    echo "❌ Error: Script not found: $SCRIPT_NAME"
    exit 1
fi

echo "🚀 Running '$SCRIPT_NAME' in parallel inside all registered worktrees..."
echo ""

# Get registered Git worktree paths
git worktree list --porcelain | awk '/^worktree / {print $2}' | while read -r worktree_path; do
  # Only process worktrees inside the target dir
  if [[ "$worktree_path" == "$WORKTREE_DIR"* ]]; then
    echo "🧵 Spawning: $worktree_path"

    if [[ -x "$worktree_path/$SCRIPT_NAME" ]]; then
      if $LOG_OUTPUT; then
        (cd "$worktree_path" && "./$SCRIPT_NAME") > "$worktree_path/output.log" 2>&1 &
      else
        (
          echo "📂 [$worktree_path]"
          cd "$worktree_path" && "./$SCRIPT_NAME"
          echo "✅ [$worktree_path] finished"
        ) &
      fi
    elif [[ -f "$worktree_path/$SCRIPT_NAME" ]]; then
      if $LOG_OUTPUT; then
        (cd "$worktree_path" && bash "$SCRIPT_NAME") > "$worktree_path/output.log" 2>&1 &
      else
        (
          echo "📂 [$worktree_path]"
          cd "$worktree_path" && bash "$SCRIPT_NAME"
          echo "✅ [$worktree_path] finished"
        ) &
      fi
    else
      echo "❌ Script not found in $worktree_path — skipping"
    fi
  fi
done

# Wait for all parallel jobs to finish
wait

echo ""
echo "🏁 All worktree scripts completed."
