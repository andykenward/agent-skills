#!/usr/bin/env bash
# Checks that both installers the README documents (vercel-labs/skills and
# microsoft/apm) install every skill in skills/, by installing from this
# checkout into a throwaway project and looking for each SKILL.md on disk.
# Both skip a skill they can't parse (bad YAML frontmatter, for example) with
# only a warning, so a zero exit code alone proves nothing.
set -euo pipefail

repo=$(cd "$(dirname "$0")/../.." && pwd)
expected=$(find "$repo/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -printf '%h\n' | xargs -n1 basename | sort)
count=$(echo "$expected" | wc -l)
# Resolve the tools from the repo's mise.toml before leaving the repo: mise only
# activates them inside it, and `mise -C` would also change the working directory.
skills_bin=$(cd "$repo" && mise which skills)
apm_bin=$(cd "$repo" && mise which apm)
node_bin_dir=$(cd "$repo" && dirname "$(mise which node)")
export PATH="$node_bin_dir:$PATH"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
status=0

# check <installer> <directory the skills land in> <install command...>
check() {
  local installer=$1 skills_dir=$2
  shift 2
  local project="$work/$installer" output missing=""
  mkdir -p "$project"
  output=$(cd "$project" && "$@" 2>&1) || {
    printf '%s\n' "$output"
    echo "$installer: install failed"
    status=1
    return
  }
  for name in $expected; do
    [ -f "$project/$skills_dir/$name/SKILL.md" ] || missing="$missing $name"
  done
  if [ -n "$missing" ]; then
    printf '%s\n' "$output" | tail -30
    echo "$installer: did not install:$missing"
    status=1
  else
    echo "$installer: installed all $count skills"
  fi
}

check skills .claude/skills "$skills_bin" add "$repo" --skill '*' --agent claude-code --yes
check apm .agents/skills "$apm_bin" install "$repo" --target agent-skills
exit "$status"
