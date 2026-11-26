#!/usr/bin/env bash
# Checks that both installers the README documents (vercel-labs/skills and
# microsoft/apm) discover every skill in skills/, by installing from this
# checkout into a throwaway project. A skill one of them can't parse (bad
# YAML frontmatter, for example) is skipped with only a warning, so compare
# the names each one reports against the folders.
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
expected=$(find "$repo/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -printf '%h\n' | xargs -n1 basename | sort)
# Resolve the tools from the repo's mise.toml before leaving the repo: mise only
# activates them inside it, and `mise -C` would also change the working directory.
skills_bin=$(cd "$repo" && mise which skills)
apm_bin=$(cd "$repo" && mise which apm)
node_bin_dir=$(cd "$repo" && dirname "$(mise which node)")
export PATH="$node_bin_dir:$PATH"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
status=0

skills_output=$("$skills_bin" add "$repo" --list 2>&1)
found=$(printf '%s\n' "$skills_output" | sed -nE 's/^│    ([a-z0-9-]+)$/\1/p' | sort)
if [ "$found" != "$expected" ]; then
  echo "skills: expected [$(echo $expected)], found [$(echo $found)]"
  printf '%s\n' "$skills_output" | grep SKIPPED || true
  status=1
else
  echo "skills: found all $(echo "$expected" | wc -l) skills"
fi

apm_output=$("$apm_bin" install "$repo" --target agent-skills 2>&1) || {
  printf '%s\n' "$apm_output"
  exit 1
}
for name in $expected; do
  if [ ! -f "$work/.agents/skills/$name/SKILL.md" ]; then
    echo "apm: $name was not installed"
    status=1
  fi
done
[ "$status" -ne 0 ] || echo "apm: installed all $(echo "$expected" | wc -l) skills"
[ "$status" -eq 0 ] || printf '%s\n' "$apm_output" | tail -20
exit "$status"
