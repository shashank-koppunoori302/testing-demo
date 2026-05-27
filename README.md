# fe-test-kit

A portable AI agent plugin for writing high-quality frontend tests. Runs a structured pipeline: discover what matters → plan scenarios → write behavioral tests → remember decisions.

Works with any frontend framework. Compatible with Claude Code, Cursor, Codex, GitHub Copilot, and Gemini CLI.

---

## Install

```bash
npx fe-test-kit
```

Auto-detects which agents are installed and copies files to the right place. No manual steps.

---

## What it does

- **Asks before it writes.** Discovery questions before reading any code.
- **Plans before it builds.** Proposes 4-5 scenarios for your approval — no code until you confirm.
- **Writes behavioral tests.** User action → observable outcome. Not smoke tests, not coverage padding.
- **Runs and verifies.** Executes tests immediately after writing. Never claims success without seeing them pass.
- **Verifies before delivering.** Checks every test against 5 critical anti-patterns and fixes violations before you see the output.
- **Gets smarter each session.** Stores decisions and patterns across sessions so you never repeat the same conversation.

---

## Skills

| Skill | When to use |
|---|---|
| `/fe-testing-setup` | **Once per project.** Scans the repo, detects the stack, creates `.testing-context.md`. |
| `/fe-test` | **Every time you write tests.** Full pipeline: discover → plan → write → run → remember. |
| `/fe-test-learn` | **Ad-hoc only.** Save a decision or learning outside of a test session. |

Start with `/fe-testing-setup`, then use `/fe-test` for everything after.

---

## First use

```
/fe-testing-setup
```

Scans the repo, asks three questions (framework, product purpose, critical flows), and creates `.testing-context.md` at the project root. Commit that file — your whole team benefits from it on their first session.

Then for every test session:

```
/fe-test
```

The pipeline asks what to test, proposes scenarios, writes the tests, runs them, and updates the context file when done.

---

## File structure

```
skills/
├── fe-test/
│   ├── SKILL.md                       ← full pipeline orchestrator
│   ├── knowledge/
│   │   └── global-learnings.md        ← cross-session patterns (grows over time)
│   └── references/
│       ├── behavioral-theory.md       ← why we test and how
│       ├── bad-patterns.md            ← 5 anti-patterns checked before delivery
│       ├── quality-gates.md           ← 3 good pattern anchors
│       └── adapters/
│           └── svelte.md              ← Svelte 4 + Vitest gotchas
├── fe-testing-setup/
│   └── SKILL.md                       ← one-time repo setup
└── fe-test-learn/
    └── SKILL.md                       ← ad-hoc memory saves
```

`.testing-context.md` lives at your **project root** (not inside this plugin). It records what the product does, its critical flows, and a session log. Commit it so it travels with the repo.

---

## Self-learning

`knowledge/global-learnings.md` starts pre-seeded with patterns from real frontend testing sessions. It grows as you work:

- At the end of each `/fe-test` session, the plugin asks once: "Save anything to memory?"
- `/fe-test-learn` lets you save decisions outside of a test session
- The file is capped at 30 entries — you'll be prompted to trim when it gets large

**On reinstall:** `global-learnings.md` and `.testing-context.md` are never overwritten. Your accumulated knowledge is safe across updates.

---

## Adding a framework adapter

The plugin works without an adapter — it falls back to the agent's training knowledge. Adapters are built from real sessions, not invented upfront:

1. Run `/fe-test` on your project
2. When you hit framework-specific gotchas, `/fe-test-learn` saves them
3. After a few sessions, extract them into `skills/fe-test/references/adapters/<framework>.md`

The Svelte adapter wasn't written on day 1 — it accumulated from real failures. Build yours the same way.

---

## License

MIT
