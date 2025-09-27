#!/usr/bin/env bash
set -e

# Check for required files
if [[ ! -f dates.txt ]]; then
  echo "❌ dates.txt not found!"
  exit 1
fi

if [[ ! -f times.txt ]]; then
  echo "❌ times.txt not found!"
  exit 1
fi

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🔎 Dry run mode enabled — no commits will be made."
fi

TARGET_FILE="history.log"

# --- NEW: Store starting commit hash for rollback ---
START_COMMIT=$(git rev-parse HEAD)
echo "$START_COMMIT" > .rollback_commit

touch "$TARGET_FILE"
git add "$TARGET_FILE"

echo "📅 Starting commit generation..."
while IFS= read -r DATE; do
  [[ -z "$DATE" ]] && continue

  while IFS= read -r TIME; do
    [[ -z "$TIME" ]] && continue

    FULL_DATE="$DATE $TIME"

    if $DRY_RUN; then
      echo "📝 Would create commit for $FULL_DATE"
    else
      export GIT_AUTHOR_DATE="$FULL_DATE"
      export GIT_COMMITTER_DATE="$FULL_DATE"

      echo "Commit on $FULL_DATE" >> "$TARGET_FILE"
      git add "$TARGET_FILE"
      git commit -q -m "Commit on $FULL_DATE"

      echo "✅ Commit created for $FULL_DATE"
    fi
  done < times.txt
done < dates.txt

if $DRY_RUN; then
  echo "🚫 Dry run complete — no commits or pushes were made."
else
  echo "🚀 Pushing all commits to origin/main..."
  git push origin main
  echo "🎉 Done! Rollback point saved in .rollback_commit"
fi
