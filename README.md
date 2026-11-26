# agent-skills

My agent skills, in the [Agent Skills](https://agentskills.io) format. Each skill lives in its own folder at `skills/<name>/SKILL.md`, which both installers below discover.

## Install

### [skills](https://github.com/vercel-labs/skills) (npx)

```bash
# Choose skills and agents interactively
npx skills add andykenward/agent-skills

# One skill, one agent, global
npx skills add andykenward/agent-skills --skill tiger-style -a claude-code -g

# List what's available
npx skills add andykenward/agent-skills --list
```

### [APM](https://github.com/microsoft/apm)

```bash
# Whole collection
apm install andykenward/agent-skills

# One skill (saved to your apm.yml)
apm install andykenward/agent-skills --skill tiger-style
```

Or declare it in your project's `apm.yml`:

```yaml
dependencies:
  apm:
    - git: andykenward/agent-skills
      skills:
        - tiger-style
```

## Skills

| Skill | Description |
| ----- | ----------- |
| [tiger-style](skills/tiger-style/SKILL.md) | Write and review code in TigerBeetle's TigerStyle, in any language |

## Development

The repo has a [dev container](.devcontainer/devcontainer.json) from [andykenward/devcontainers-templates](https://github.com/andykenward/devcontainers-templates) (`dev` template), with Node, the GitHub CLI and Claude Code. Open it in VS Code with **Dev Containers: Reopen in Container**, or run `devcontainer up --workspace-folder .`.

Tools are pinned in [mise.toml](mise.toml) and [mise.lock](mise.lock), and the dev container installs them on create. Run the checks CI runs with:

```bash
mise run lint
```

That validates every skill against the [Agent Skills spec](https://agentskills.io), checks that both `npx skills` and `apm` find every skill, checks the table above lists them all, and lints the workflows with actionlint and zizmor.

## Adding a skill

```bash
npx skills init skills/my-skill
```

Then edit `skills/my-skill/SKILL.md`. The frontmatter needs `name` (lowercase, hyphens, matching the folder) and `description` (what it does and when to use it). Add the skill to the table above.
