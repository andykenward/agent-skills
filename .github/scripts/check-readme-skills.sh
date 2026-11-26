#!/usr/bin/env bash
# Checks that every skill in skills/ has a row in the README's Skills table,
# and that every row links to a skill that exists.
set -euo pipefail
cd "$(dirname "$0")/../.."

status=0
for dir in skills/*/; do
  name=$(basename "$dir")
  if ! grep -qF "| [$name](skills/$name/SKILL.md) |" README.md; then
    echo "README.md: no row in the Skills table for $name"
    status=1
  fi
done
for path in $(grep -oE '\(skills/[^)]+/SKILL\.md\)' README.md | tr -d '()'); do
  if [ ! -f "$path" ]; then
    echo "README.md: links to $path, which doesn't exist"
    status=1
  fi
done
exit "$status"
