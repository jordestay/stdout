#!/usr/bin/env bash
set -e

if [[ ! -f .rollback_commit ]]; then
  echo "❌ No rollback point found. (Did you run generate_commits.sh?)"
  exit 1
fi

ROLLBACK_COMMIT=$(cat .rollback_commit)

echo "⚠️ This will reset main to commit: $ROLLBACK_COMMIT"
echo "You can also restore 'history.log' to its state before the generated commits."
read -p "Type 'YES' to confirm rollback: " CONFIRM

if [[ "$CONFIRM" == "YES" ]]; then
  echo "🔄 Resetting local branch to $ROLLBACK_COMMIT..."
  git reset --hard "$ROLLBACK_COMMIT"

  # Ask if we should restore history.log
  if [[ -f history.log ]]; then
    read -p "Restore history.log to its state from $ROLLBACK_COMMIT? (y/N): " RESTORE_LOG
    if [[ "$RESTORE_LOG" =~ ^[Yy]$ ]]; then
      git checkout "$ROLLBACK_COMMIT" -- history.log || echo "ℹ️ history.log not tracked at rollback commit."
      echo "📜 history.log restored."
    else
      echo "ℹ️ history.log left as-is."
    fi
  fi

  echo "🚀 Force pushing to origin/main..."
  git push origin main --force

  echo "✅ Rollback complete! Contribution graph will update shortly."
else
  echo "❌ Rollback canceled."
fi
