# fe-test

Frontend testing skill installer for AI coding agents.

Installs the `fe-test` skill into Claude Code, Cursor, GitHub Copilot, Gemini CLI, and Codex.

## Usage

```bash
npx fe-test
```

Run in your project directory. Prompts you to pick which agents to install for.

## Flags

```bash
npx fe-test --claude       # Claude Code (project-level)
npx fe-test --claude-user  # Claude Code (user-level, all your projects)
npx fe-test --cursor       # Cursor
npx fe-test --copilot      # GitHub Copilot
npx fe-test --gemini       # Gemini CLI
npx fe-test --codex        # Codex / agentskills.io
npx fe-test --all          # All agents
```

## What gets installed

| Skill | Command | Purpose |
|---|---|---|
| `fe-test` | `/fe-test` | Full testing pipeline: discover → plan → write → verify |
| `fe-test-learn` | `/fe-test-learn` | Save decisions and patterns to memory |

## Reinstalls are safe

Running `npx fe-test` again on an existing install updates managed skill files only.
Your `global-learnings.md`, `.testing-context.md`, and `.testing-log.md` are never touched.

## Requirements

Node ≥ 18
