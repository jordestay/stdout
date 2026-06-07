#!/bin/bash

dates=(
"1970-01-01"

  # add more dates here
)

for date in "${dates[@]}"; do
  for i in 0 1 2 3 4; do
    timestamp="${date}T12:$(printf '%02d' $((i * 5))):00-05:00"
    GIT_AUTHOR_DATE="$timestamp" \
    GIT_COMMITTER_DATE="$timestamp" \
    git commit --allow-empty -m "backdate test - Unix epoch start"
  done
done