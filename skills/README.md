# Frontend Testing Plugin

A portable AI agent plugin for writing high-quality frontend tests. Runs a
structured pipeline: discover what matters → plan scenarios → write behavioral
tests → remember decisions.

Best supported with Vite + Svelte today — adaptable to any frontend framework.
Compatible with Claude Code, Cursor, Codex, GitHub Copilot, Gemini CLI, and any
agent that follows the agentskills.io standard.

---

## What it does

- **Scans before it asks.** Reads the codebase silently first, then confirms only what it couldn't infer.
- **Plans before it builds.** Proposes scenarios for your approval — no code until you confirm.
- **Writes behavioral tests.** User action → observable outcome. Not smoke tests, not coverage padding.
- **Verifies before delivering.** Checks every test against critical anti-patterns and fixes violations before you see the output.
- **Gets smarter each session.** Stores decisions and patterns across sessions so you never repeat the same conversation.

---

## Skills

| Skill | When to use |
|---|---|
| `/fe-test init` | **Once per project.** Scans the repo, infers what it can, asks only what code can't answer. Creates `.testing-context.md`. |
| `/fe-test` | **Every time you write tests.** If no context file exists, runs init automatically first. Full pipeline: discover → plan → write → remember. |
| `/fe-test-learn` | **Ad-hoc only.** Save a decision or learning outside of a test session. |

There is only one entry point: `/fe-test`. Everything starts there.

---

## Install

Choose the path that matches your agent:

### Claude Code
```bash
# Project-level (committed to git, shared with team)
cp -r .agents/skills/fe-test .claude/skills/
cp -r .agents/skills/fe-test-learn .claude/skills/

# Or personal (available in all your projects)
cp -r .agents/skills/fe-test ~/.claude/skills/
cp -r .agents/skills/fe-test-learn ~/.claude/skills/
```

### Cursor
```bash
cp -r .agents/skills/fe-test .cursor/skills/
cp -r .agents/skills/fe-test-learn .cursor/skills/
```

### Codex / any agentskills.io-compatible agent
The `.agents/skills/` directory is the standard location — no copy needed.

### GitHub Copilot
```bash
cp -r .agents/skills/fe-test .github/copilot/skills/
cp -r .agents/skills/fe-test-learn .github/copilot/skills/
```

### Gemini CLI
```bash
cp -r .agents/skills/fe-test ~/.gemini/skills/
cp -r .agents/skills/fe-test-learn ~/.gemini/skills/
```

---

## First use

```
/fe-test init
```

This scans `package.json`, test configs, and page/route files silently. It infers
the framework, test runner, and candidate critical flows from the code — then
confirms only what it couldn't infer. Creates `.testing-context.md` at the project
root. You'll be prompted whether to commit it — your whole team benefits from it.

If you skip init and go straight to `/fe-test`, it detects the missing context
file and runs init automatically before starting the test session.

Then for every test session:

```
/fe-test
```

That's it. The pipeline asks what to test, proposes scenarios, writes the tests,
and updates the context file when done.

---

## File structure

```
.agents/skills/
├── README.md                          ← this file
├── fe-test/
│   ├── SKILL.md                       ← full pipeline: init + discover + plan + write + learn
│   ├── knowledge/
│   │   └── global-learnings.md        ← cross-session patterns (grows over time)
│   └── references/
│       ├── behavioral-theory.md       ← why we test and how
│       ├── bad-patterns.md            ← anti-patterns checked before delivery
│       ├── quality-gates.md           ← 3 good pattern anchors
│       └── adapters/
│           └── svelte.md              ← Svelte 4 + Vitest gotchas
├── fe-test-learn/
│   └── SKILL.md                       ← ad-hoc memory saves
└── fe-testing-setup/
    └── SKILL.md                       ← deprecated, redirects to /fe-test init
```

`.testing-context.md` lives at your **project root** (not inside this plugin).
It records what the product does, its critical flows, and a session log.
Commit it so it travels with the repo.

---

## Adding a framework adapter

If your project uses React, Vue, Angular, or another framework, the plugin works
without an adapter — it falls back to the agent's training knowledge. To add
specific gotchas and patterns:

1. Create `.agents/skills/fe-test/references/adapters/react.md` (or vue.md, etc.)
2. Follow the same structure as `adapters/svelte.md`
3. The plugin loads it automatically when the framework is detected

---

## Self-learning

`knowledge/global-learnings.md` starts pre-seeded with 22 patterns from real
frontend testing sessions. It grows as you work:

- `/fe-test-learn` lets you save decisions, patterns, and gotchas any time
- The file is capped at 30 entries — you'll be prompted to trim when it gets large

The more sessions you run, the more it knows about your preferences and the
patterns that matter in your codebase.
