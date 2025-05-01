#!/usr/bin/env bash
set -euo pipefail

# === Usage Help ===
show_help() {
  echo ""
  echo "📘 Usage:"
  echo "  ./generate_commits_and_tags.sh <total_commits> <playable_tags> <working_tags>"
  echo ""
  echo "🔧 Parameters:"
  echo "  <total_commits>   Number of commits to generate (e.g., 20)"
  echo "  <playable_tags>   Number of commits to tag with playable-[timestamp]"
  echo "  <working_tags>    Number of commits to tag with working-[timestamp]"
  echo ""
  echo "💡 Example:"
  echo "  ./generate_commits_and_tags.sh 30 7 4"
  echo ""
  exit 1
}

# === Validate Input ===
if [[ "${1:-}" == "--help" ]] || [[ $# -ne 3 ]]; then
  show_help
fi

TOTAL_COMMITS=$1
PLAYABLE_TAGS=$2
WORKING_TAGS=$3

# === Check that numbers are valid integers ===
if ! [[ "$TOTAL_COMMITS" =~ ^[0-9]+$ && "$PLAYABLE_TAGS" =~ ^[0-9]+$ && "$WORKING_TAGS" =~ ^[0-9]+$ ]]; then
  echo "❌ Error: All arguments must be positive integers."
  show_help
fi

if [[ "$PLAYABLE_TAGS" -gt "$TOTAL_COMMITS" || "$WORKING_TAGS" -gt "$TOTAL_COMMITS" ]]; then
  echo "❌ Error: Tag counts cannot exceed total commit count."
  exit 1
fi

# === Target file to mutate for commits ===
TARGET_FILE="demo.txt"
touch "$TARGET_FILE"

# === Random commit indices for tagging ===
playable_indices=($(shuf -i 1-"$TOTAL_COMMITS" -n "$PLAYABLE_TAGS"))
working_indices=($(shuf -i 1-"$TOTAL_COMMITS" -n "$WORKING_TAGS"))

# === Info ===
echo "🎯 Configuration:"
echo "   Commits:          $TOTAL_COMMITS"
echo "   Playable tags:    $PLAYABLE_TAGS → ${playable_indices[*]}"
echo "   Working tags:     $WORKING_TAGS → ${working_indices[*]}"
echo ""

# === Commit Generation Loop ===
for i in $(seq 1 "$TOTAL_COMMITS"); do
  echo "Line $i: $(date)" >> "$TARGET_FILE"
  git add "$TARGET_FILE"
  git commit -m "Commit #$i"

  commit_hash=$(git rev-parse HEAD)
  timestamp=$(date +"%Y_%m_%d_%H_%M_%S")

  if [[ " ${playable_indices[*]} " =~ " $i " ]]; then
    tag_name="playable-$timestamp"
    git tag "$tag_name" "$commit_hash"
    echo "🏷️  Tagged commit #$i with $tag_name"
  fi

  if [[ " ${working_indices[*]} " =~ " $i " ]]; then
    tag_name="working-$timestamp"
    git tag "$tag_name" "$commit_hash"
    echo "🏷️  Tagged commit #$i with $tag_name"
  fi

  sleep 1  # Ensure unique timestamps
done

echo ""
echo "✅ Done. Use './push_commits_and_tags.sh' to push commits and tags."
