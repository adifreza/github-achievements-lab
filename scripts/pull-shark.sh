#!/usr/bin/env bash
# Bikin + merge N PR kecil untuk Pull Shark.
# Pakai: bash scripts/pull-shark.sh 5
# Butuh: gh sudah login, branch default = main.
set -euo pipefail

N="${1:-2}"
BASE="${2:-main}"

git checkout "$BASE"
git pull --ff-only

for i in $(seq 1 "$N"); do
  ts="$(date +%s)"
  branch="chore/log-${ts}-${i}"

  git checkout -b "$branch"
  echo "- entry ${ts}-${i} ($(date -u +%FT%TZ))" >> docs/log.md
  git add docs/log.md
  git commit -m "docs: log entry ${ts}-${i}"
  git push -u origin "$branch"

  gh pr create --base "$BASE" --head "$branch" \
    --title "docs: log entry ${ts}-${i}" \
    --body "Perubahan kecil untuk latihan Pull Shark."

  # --admin dipakai kalau ada branch protection; kalau tidak ada, aman diabaikan.
  gh pr merge "$branch" --squash --delete-branch --admin || \
  gh pr merge "$branch" --squash --delete-branch

  git checkout "$BASE"
  git pull --ff-only
  echo "PR $i selesai di-merge."
done

echo "Selesai. $N PR ter-merge."
