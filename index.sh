#!/usr/bin/env bash
set -euo pipefail

# === Configuration ===
TOTAL_COMMITS=20    # Number of commits to generate
PLAYABLE_TAGS=5     # Number of playable tags to create
WORKING_TAGS=3      # Number of working tags to create

# === Helper Functions ===
confirm() {
    read -r -p "⚠️  $1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) true ;;
        *) false ;;
    esac
}

print_step() {
    echo ""
    echo "=== $1 ==="
    echo ""
}

# === Main Script ===
echo "🎮 Git Worktree Learning Application"
echo "This script will run through all steps of the worktree learning process."
echo ""

# Step 1: Cleanup (Optional)
if confirm "Would you like to clean up existing worktrees and reset the repository first?"; then
    print_step "Cleaning Up"
    if [ -f "util/cleanup_worktrees.sh" ]; then
        ./util/cleanup_worktrees.sh
    fi
    
    if confirm "Would you like to completely reset the git repository? (This will erase all history)"; then
        ./util/reset_git_repo.sh
    fi
fi

# Step 2: Generate Commits and Tags
print_step "Generating Commits and Tags"
echo "Creating $TOTAL_COMMITS commits with $PLAYABLE_TAGS playable tags and $WORKING_TAGS working tags"
./1-generate_commits_and_tags.sh "$TOTAL_COMMITS" "$PLAYABLE_TAGS" "$WORKING_TAGS"

# Step 3: Push to Remote
print_step "Pushing to Remote"
./2-push_commits_and_tags.sh

# Step 4: Create Worktrees
print_step "Creating Worktrees"
./3-create_worktrees_and_branches_from_tags.sh

# Step 5: Run Scripts in Worktrees
print_step "Running Scripts in Worktrees"
echo "This will run demo_script.sh in all worktrees in parallel."
if confirm "Would you like to proceed?"; then
    ./4-run_all_worktrees_in_parallel.sh
fi

echo ""
echo "✅ All steps completed successfully!"
echo "You can find your worktrees in the ../worktrees directory"
