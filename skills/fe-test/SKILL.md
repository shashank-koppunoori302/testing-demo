---
name: fe-test
description: Frontend testing pipeline. Use when asked to write, create, or add tests for any component, service, file, or feature. Runs the full discover → plan → write → learn pipeline in one session. Works with any frontend framework.
---

You are running the full frontend testing pipeline. Follow every step in order.
Never skip ahead. Never write test code before Step 4.

---

## Step 1 — Load context (silent, no questions yet)

Read `knowledge/global-learnings.md` — apply everything in it to this session.

Check if `.testing-context.md` exists at the project root.

**If it exists:** Read it. You already know the product, the critical flows, and
prior decisions. Skip any question whose answer is already there.

**If it does not exist — ask these three questions before anything else:**

> "This looks like a first session. I need three things before we start:
>
> 1. What framework is this project using? (React, Vue, Svelte, Angular, other)
> 2. What does this product do for users? One sentence.
> 3. What are the 3-5 most critical user flows — the ones where a bug would hurt users most?"

Wait for all three answers. Then immediately create `.testing-context.md`
at the project root — do not wait until the end of the session:

```markdown
# Testing Context — [project name]

## What this product does
[Answer to question 2]

## Critical user flows
[Answer to question 3]

## Testing decisions
- Framework: [Answer to question 1]

## Sessions
- [today's date]: First session.
```

Do not invent any of these answers. Use exactly what the user said.

---

## Step 2 — Discover

Ask:
> "Which file or feature should I write tests for?"

Wait for their answer.

**Check for existing tests first:**

Look for a test file for what they named. Common locations:
`__tests__/`, `.test.ts`, `.spec.ts` alongside the source file.

- **Test file found:** Read it. Note what's already covered.
  Say: "You already have [N] tests covering [X, Y, Z]. I'll focus on the gaps."
  Run discovery only on uncovered areas.
- **No test file:** Run full discovery.

**Make the unit vs integration call:**

Does this have UI?
- **No** (pure function, utility, service): → unit tests. Input → output. Many edge cases. No rendering.
- **Yes** (component, page, flow): → integration tests. Real services, only HTTP mocked. Assert what the user sees.

State the approach clearly:
> "This is a [pure function / UI component] — I'll write [unit / integration] tests."

**Ask all five questions at once:**

1. What does this do for the user?
2. What would break their experience if it stopped working?
3. What different states or conditions does this handle?
4. Has this caused bugs or regressions before?
5. What already has tests nearby that we can rely on?

> "Answer whatever's relevant, skip anything that doesn't apply."

Wait for their answers. Produce a journey map:

```
Journey map: [Name]
Approach: [Unit / Integration]

Test these:
1. [Happy path]
2. [Primary failure path]
3. [Edge case or alternative state]

Skip these:
- [Path]: [reason — already covered / cosmetic / stale / low risk]
```

Ask: "Does this cover what matters?"
**Wait for confirmation before continuing.**

---

## Step 3 — Plan

From the confirmed journey map, select 4-5 scenarios.

Priority: failure/error paths first → happy path → edge cases.

For each, use Rule of Three naming:
**[What] — when [condition] — [user observes X]**

```
Scenario N: [Name following Rule of Three]
Setup:   [What state is needed]
Action:  [What the user or system does]
Outcome: [What the user observes]
Catches: [What regression this protects against]
```

After all scenarios:
> "Approve all, or tell me which to adjust, remove, or add."

**Do not write any code until the user confirms.**

---

## Step 4 — Write, verify, remember, deliver

Read [references/bad-patterns.md](references/bad-patterns.md) now.
Read [references/quality-gates.md](references/quality-gates.md) now.

Check [references/adapters/](references/adapters/) for the detected framework.
If an adapter exists — read it for non-obvious gotchas. If none exists —
use your training knowledge. Adapters expand knowledge, not gate execution.

If you hit any framework-specific gotchas while writing — add them to
`references/adapters/<framework>.md`. Create the file if it doesn't exist yet.
Adapters are built from real failures, not pre-written. Don't invent entries.

Write exactly the confirmed scenarios. No extras. One test per scenario.

Assert on observable outcomes only:
- Text the user reads
- Element present or absent based on meaningful state
- Interaction + behavioral proof (not just a visual class alone)
- Store or state value that directly drives what renders
- Exact API payload when the contract matters

Keep tests self-contained. A failing test should be debuggable by reading one file.

**Verify silently:**

Check every test against bad-patterns.md before showing anything.
Fix violations first. If you fixed something, note it briefly:
> "Fixed: [pattern name] at [location]"

If no violations — deliver without comment.

Ratio check: if more than half the tests have no user-visible assertion, pause:
> "Most tests here assert on internal state — intentional for a service test, or should we adjust?"

**Before delivering — ask once:**

> "Should I save anything from this session to memory? [yes — what / no]"

If yes: write to `knowledge/global-learnings.md`

```
## [Title — max 8 words]
**Decision:** [One sentence]
**Why:** [One sentence]
```

Check for duplicates first. Update existing entries, never add duplicates.
If over 30 entries: "The learnings file is getting long. Want to trim it?"

**Then deliver:**

The complete test file. Then one line:
> "N tests written. Covers: [scenario names]. Run with: [test command]."

**Run and verify:**

Run the test command immediately after delivering. Do not ask — just run it.

- All pass → report: "All N tests passing."
- Some fail → read the error output. Diagnose and fix silently. Re-run. Report once clean.
- Type errors → fix them. Re-run.
- If a fix requires a design change (wrong assumption about the component) → stop, show the error, explain what assumption was wrong, ask before changing.

Never claim success without having run the tests and seen them pass.

If you spotted gaps while writing, note them after:
> "I also noticed [X] isn't covered. Want to plan that next?"

---

## Step 5 — Update context

Always append a session note to `.testing-context.md` at the project root:

```
## Sessions
- [date]: [file/feature tested]. [One-line summary of anything notable.]
```

Commit `.testing-context.md` if it was just created. It travels with the
repo — every agent and every team member reads it on their first session.
