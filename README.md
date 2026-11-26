# agent-skills

My agent skills, in the [Agent Skills](https://agentskills.io) format. Each skill lives in its own folder at `skills/<name>/SKILL.md`, which both installers below discover.

## Install

### [skills](https://github.com/vercel-labs/skills) (npx)

```bash
# Choose skills and agents interactively
npx skills add andykenward/agent-skills

# One skill, one agent, global
npx skills add andykenward/agent-skills --skill example-skill -a claude-code -g

# List what's available
npx skills add andykenward/agent-skills --list
```

### [APM](https://github.com/microsoft/apm)

```bash
# Whole collection
apm install andykenward/agent-skills

# One skill (saved to your apm.yml)
apm install andykenward/agent-skills --skill example-skill
```

Or declare it in your project's `apm.yml`:

```yaml
dependencies:
  apm:
    - git: andykenward/agent-skills
      skills:
        - example-skill
```

## Skills

| Skill | Description |
| ----- | ----------- |
| [example-skill](skills/example-skill/SKILL.md) | Placeholder that confirms installs work |

## Development

The repo has a [dev container](.devcontainer/devcontainer.json) from [andykenward/devcontainers-templates](https://github.com/andykenward/devcontainers-templates) (`dev` template), with Node, the GitHub CLI and Claude Code. Open it in VS Code with **Dev Containers: Reopen in Container**, or run `devcontainer up --workspace-folder .`.

## Adding a skill

```bash
npx skills init skills/my-skill
```

Then edit `skills/my-skill/SKILL.md`. The frontmatter needs `name` (lowercase, hyphens, matching the folder) and `description` (what it does and when to use it). Add the skill to the table above.
