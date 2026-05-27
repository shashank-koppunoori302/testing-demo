# fe-test

A skill for AI coding agents that writes frontend tests.

Works with Claude Code, Cursor, GitHub Copilot, Gemini CLI, and Codex.

---

## What it does

`fe-test` runs a structured pipeline every time you write tests:

1. **Discover** — scans the codebase silently, maps coverage against your critical flows
2. **Plan** — proposes test scenarios for your approval (no code written until you confirm)
3. **Write** — writes behavioral tests: user action → observable outcome
4. **Verify** — checks every test against 8 anti-patterns and fixes violations before you see output
5. **Log** — appends a session entry to `.testing-log.md` so future sessions know what's been covered

---

## What kind of tests it writes

- **Unit tests** — pure functions, validators, formatters, helpers
- **Component tests** — rendering, props, conditional UI, local interactions
- **Integration tests** — components that touch APIs, stores, router, permissions, or child components

Tests assert on what the user observes — visible text, elements present or absent, interactions with behavioral proof. Not smoke tests, not coverage padding.

Anti-patterns it catches before delivery:
- Smoke assertions (`expect(container).not.toBeNull()` as the only check)
- Placeholders (`expect(true).toBe(true)`)
- Mock-call-only assertions (proves mock fired, not that the user saw anything)
- Machine-specific paths (breaks CI and every other dev's machine)
- Loose rejection checks
- Excessive mocking (mocks so much that real code never runs)
- Testing library/framework behavior (re-verifying code you didn't write)
- CSS class assertions without behavioral proof

---

## Install

**Interactive (recommended):**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/shashank-koppunoori302/fe-test-kit/main/install.sh)
```

Prompts you to pick which agents to install for.

**With flags (non-interactive):**
```bash
curl -fsSL https://raw.githubusercontent.com/shashank-koppunoori302/fe-test-kit/main/install.sh | bash -s -- --claude
```

Available flags:

| Flag | Installs to |
|---|---|
| `--claude` | `.claude/skills/` (project-level, commit to git) |
| `--claude-user` | `~/.claude/skills/` (all your projects) |
| `--cursor` | `.cursor/skills/` |
| `--copilot` | `.github/copilot/skills/` |
| `--gemini` | `~/.gemini/skills/` |
| `--codex` | `.agents/skills/` |
| `--all` | All of the above |

---

## Usage

Once installed, use these commands inside your agent:

| Command | When to use |
|---|---|
| `/fe-test init` | **Once per project.** Scans the repo, infers framework and critical flows, creates `.testing-context.md`. |
| `/fe-test` | **Every test session.** Full pipeline: discover → plan → write → log. Runs init automatically if no context file exists. |
| `/fe-test <filename>` | Target a specific file. e.g. `/fe-test PaymentButton.svelte` |
| `/fe-test-learn` | Save a decision or pattern to memory outside of a test session. |

---

## Reinstalls are safe

Running the install script again on an existing install updates managed skill files only.
Your `global-learnings.md`, `.testing-context.md`, and `.testing-log.md` are never overwritten.

---

## Requirements

`curl` and `bash` — that's it. No Node, no npm.
