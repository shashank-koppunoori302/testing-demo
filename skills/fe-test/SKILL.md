---
name: fe-test
description: Frontend testing pipeline. Use when asked to write, create, or add tests for any component, service, file, or feature. Supports `/fe-test init` for first-time repo setup — scans the codebase and asks only what code can't answer. Runs the full discover → plan → write → learn pipeline in one session. Works with any frontend framework.
---

You are running the full frontend testing pipeline. Follow every step in order.
Never skip ahead. Never write test code before Step 4.

---

## Entry — detect invocation mode

**Did the user type `/fe-test init`?**
→ Jump to [Init](#init) now. Skip Steps 1–5.

**Did the user pass a name or file argument?**
(e.g. `/fe-test PaymentButton.svelte`, `/fe-test paymentbutton`, `/fe-test login flow`)
→ Check if `.testing-context.md` exists. If not, run Init first.
→ Then jump to Step 1, but carry the argument as the **pre-selected target** — Step 2 will skip the coverage map and go straight to targeted discovery on that file.

**Otherwise (`/fe-test` with no argument):**
Check if `.testing-context.md` exists at the project root.
- **Exists** → continue to Step 1.
- **Does not exist** → say: "No context file found — running init first." Then run [Init](#init), then continue to Step 1.

---

## Init — scan first, ask only what code can't answer

### Scan silently (no questions yet)

Read and grep these without asking anything:
- `package.json` — framework, test runner, utilities, project name
- Any test config present: `vitest.config.*`, `jest.config.*`, `playwright.config.*`
- Route or page-level files to infer candidate critical flows:
  - Grep the codebase for route definitions (`path:`, `<Route`, `createBrowserRouter`, `useRoutes`, `SvelteKit route`, `defineRoute`, `RouterView`) — the file that matches is the authoritative page list; read it fully
  - Also scan `src/pages/`, `src/views/`, `src/routes/`, `src/screens/` recursively — look at subdirectories, not just the top level
  - `src/App.*` and top-level `.svelte` / `.tsx` / `.vue` files as a fallback
- Grep across all test files (`**/*.test.ts`, `**/*.spec.ts`) to extract the test fingerprint:
  - `vi.mock` — factory style used
  - `import.*mock` — mock path pattern (alias vs relative — note exact form)
  - `beforeEach` — store reset style
  - `@ts-nocheck` — whether required as file header
  - `describe|it\b|test\b` — test structure pattern
  - Any custom render utilities or test helpers imported
  - Note pattern quality overall: behavioral / smoke / none / missing
  - If no test files exist: record "No existing tests — derive from framework defaults; update after first test is written"

### Build inferred context (in memory — do not write yet)

Compose the following content from the scan — hold it in memory until after confirmation:

```markdown
# Testing Context — [project name from package.json or folder]

## What this product does
[actual product description]

## Critical user flows
1. [flow name]
2. [flow name]
...

## Testing decisions
- Framework: [detected]
- Test runner: [detected or "not set up"]
- Existing pattern: [behavioral / smoke / none / missing]

## Test fingerprint
- Mock pattern: [actual pattern or "no existing tests"]
- Mock paths: [actual paths or "no existing tests"]
- Store reset: [actual style or "no existing tests"]
- Assertions: [actual style or "no existing tests"]
- Render: [actual utility or "no existing tests"]
- File header: [yes — @ts-nocheck / no]
- Test structure: [actual pattern or "no existing tests"]
- Custom helpers: [none / list if found]

## Sessions
- [today's date]: Init session.
```

### Check test infrastructure

Check the inferred testing decisions. If a test runner is already present and a config file exists → skip to **Confirm inferred context with user** below.

If no test runner is detected, set it up now.

**Show options based on detected framework** (present 2–3 relevant choices with a recommended one — don't show options that don't fit the detected framework):

**Svelte + Vite:**
```
1. Vitest + @testing-library/svelte (Recommended) — native Vite integration, fast, minimal config
2. Jest + @testing-library/svelte — familiar if coming from React, heavier config
3. Playwright — E2E only (different scope)
```

**React + Vite:**
```
1. Vitest + @testing-library/react (Recommended) — native Vite integration, fast
2. Jest + @testing-library/react — familiar, more config overhead
3. Playwright — E2E only
```

**Vue + Vite:**
```
1. Vitest + @testing-library/vue (Recommended) — native Vite integration
2. Jest + @testing-library/vue — familiar, more config
3. Playwright — E2E only
```

**Next.js:**
```
1. Jest + @testing-library/react (Recommended) — official Next.js recommendation
2. Vitest + @testing-library/react — works but needs extra config for Next.js internals
3. Playwright — E2E only
```

**Other / unknown framework:** show the most generic options and flag uncertainty.

Ask: "Which setup do you want?" Wait for their answer before proceeding.

**On confirmation — install and configure.** Example for Vitest + @testing-library/svelte:

```bash
npm install -D vitest @testing-library/svelte @testing-library/jest-dom jsdom @sveltejs/vite-plugin-svelte
```

Create `vitest.config.mts`:
```ts
import { defineConfig } from 'vitest/config';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import { svelteTesting } from '@testing-library/svelte/vite';

export default defineConfig({
  plugins: [svelte({ hot: !process.env.VITEST }), svelteTesting()],
  test: {
    environment: 'jsdom',
    setupFiles: ['test/setup.ts'],
    include: ['src/**/*.test.ts'],
  },
});
```

Create `test/setup.ts`:
```ts
import '@testing-library/jest-dom/vitest';
import { vi, afterEach } from 'vitest';

afterEach(() => {
  vi.resetAllMocks();
});
```

Add to `package.json` scripts: `"test": "vitest run"` and `"test:watch": "vitest"`.

Adapt the config to mirror patterns already found in the test fingerprint. Update the `## Testing decisions` section of `.testing-context.md` with what was installed.

### Confirm inferred context with user

Show what was inferred and ask only what the code couldn't answer:

```
Here's what I found:

Product: [inferred description or "couldn't determine"]
Critical flows:
  1. [inferred flow]
  2. [inferred flow]
  ...

Does this look right? Correct anything, or say go ahead.
```

If the description was clearly inferred (e.g. from README or package.json description) — present it as a confirmation, not a question. Only ask explicitly if nothing could be inferred.

Wait for their response. Update the in-memory content with any corrections, then write `.testing-context.md` to disk.

If the user invoked `init` explicitly → stop here.
If init ran automatically (context was missing) → continue to Step 1.

---

## Step 1 — Load context (silent, no questions)

Find `**/fe-test/knowledge/global-learnings.md` — if it exists, read it and apply everything in it to this session. If it doesn't exist, skip.

Read `.testing-context.md`. You already know the product, the critical flows, prior decisions, and the test fingerprint. Apply the fingerprint to all test writing this session — do not re-derive what is already recorded. No questions needed here.

Read the **last 30 lines** of `.testing-log.md` at the project root if it exists — do not read the full file. Use it to:
- Know which files have been tested before and when — surface this in the coverage map ("last tested 2 months ago")
- Flag files never appearing in the log as untested territory
- Note any sessions that flagged regressions or sensitive areas — treat those files as higher risk

---

## Step 2 — Discover

**Was a target pre-selected from the command?**

If yes (e.g. user typed `/fe-test PaymentButton.svelte` or `/fe-test paymentbutton`):

- Search the codebase for a file matching the name. Try exact match first, then case-insensitive partial match.
- **One match found** → confirm it: "Found `src/Components/PaymentButton.svelte` — using that." Proceed to **Check what's already covered** below. Skip the coverage map.
- **Multiple matches found** → show the list, ask which one:
  > "I found a few matches — which did you mean?
  > 1. src/Components/PaymentButton.svelte
  > 2. src/Components/PaymentButtons/PaymentButton.svelte"
- **No match** → say so and show closest names found. Ask them to clarify.

If no target was pre-selected, run the full coverage scan below.

---

**Scan silently first — no questions yet.**

Read `.testing-context.md` for the critical user flows.

For each flow, find the key files involved by scanning the codebase — look for
components, services, and utilities that implement that flow by name and structure.

For each file found, check if a test file exists (common locations: `__tests__/`,
`.test.ts`, `.spec.ts` alongside the source). Classify coverage:
- ✓ has a test file with behavioral tests
- ~ has a test file but appears shallow (smoke-only or very few tests)
- ✗ no test file

**Present the coverage map before asking anything:**

```
Coverage against your critical flows:

1. [Flow name]
   [File A]  ✓  12 tests
   [File B]  ✗  no tests
   [File C]  ~  2 tests (smoke only)

2. [Flow name]
   [File D]  ✗  no tests

3. [Flow name]
   [File E]  ✓  8 tests
   [File F]  ✓  5 tests
```

Then ask:
> "Which flow or file do you want to focus on?
> If you're not sure, I'd start with [highest-risk ✗ or ~ file] — it's in your
> critical flow with the most coverage gap."

Wait for their answer.

**Route based on what they said:**

- **Picked a flow** → find the ✗ and ~ files in that flow. Focus discovery on the
  highest-risk one. Name which file you're starting with and why.
- **Picked a specific file** → proceed with discovery on that file directly.

**Check what's already covered:**

If a test file exists for the target — read it. Note what's already covered.
Say: "You already have [N] tests covering [X, Y, Z]. I'll focus on the gaps."

**Classify the target and decide test types (silent — no user prompt):**

Read the target file fully. Then work through A → B → C internally.

**A — Classify (common types — not exhaustive, use judgment):**
- Presentational — renders props, no side effects
- Form — input handling, validation, submission
- Data-fetching — calls APIs, manages loading/error/success states
- Container/page — composes children, owns layout
- Routing/auth/permission — guards, redirects, access control
- Complex stateful — multi-step flows, timers, event chains
- Mixed / other — if the file doesn't fit cleanly, describe what it does in one phrase

**B — Identify responsibilities by reading the file (all internal):**
- What does the user see and do? (from template/render)
- What props affect behavior? (from component props)
- What external dependencies are used? (stores, services, utilities — from imports)
- What states exist: loading, error, empty, success, disabled, permission? (from conditionals)
- Are there pure functions, validators, formatters, or helpers defined in this file?

**C — Decide test types (list all that apply):**
- **Unit** → any pure functions, validators, formatters, or helpers found in the file
- **Component** → rendering, props, conditional UI, local interactions (no external deps)
- **Integration** → when the component touches API mocks, router, context, stores, permissions, or child components

Then present the combined output in one shot:

```
Target: [filename]
Classification: [type from Step A]
Test types: [unit / component / integration] — [one-line reason]
[If helpers found]: Pure helper(s): [name(s)] — flagged as unit candidates

What the code tells me:
- [State 1 / prop / behavior]: [how it renders or behaves]
- [State 2 / prop / behavior]: ...

Plan:
[All scenarios — no cap — Rule of Three naming — descriptions only]
1. [What] — when [condition] — [user observes X]
2. [What] — when [condition] — [user observes X]
...

Do not test:
- [thing]: [reason — presentational only / library behavior / already covered / no logic]
```

For each scenario, derive Setup / Action / Outcome / Catches internally — use when writing tests, do not show to user.

Only if there is something the code genuinely cannot answer (max 2):
> "One thing code can't tell me: [question]"

Then ask:
> "Go ahead, or adjust anything above."

**Wait for their response before writing any code.**

---

## Step 3 — Adjust and confirm

If the user adjusts scenarios → update only what changed, re-present the affected scenarios, ask again.
If the user says go ahead → proceed to Step 4.

**What counts as go-ahead:** "looks good", "go ahead", "write it", "yes", "approved", or any clear signal.
**What does not count:** silence, a question, or a partial correction without confirming the rest.
**If ambiguous** → ask: "Should I go ahead and write the tests?"

**Do not write any code until the go-ahead is explicit.**

---

## Step 4 — Write, verify, remember, deliver

Locate and read:
- `**/fe-test/references/bad-patterns.md`
- `**/fe-test/references/quality-gates.md`

Check if `**/fe-test/references/adapters/<framework>.md` exists (replace
`<framework>` with the detected framework name, e.g. `svelte`, `react`, `vue`).
If an adapter exists — read it for non-obvious gotchas. If none exists —
use your training knowledge. Adapters expand knowledge, not gate execution.

If you hit any framework-specific gotchas while writing — note them after delivery and ask:
> "Hit a [framework] gotcha: [description]. Want me to save it to `adapters/<framework>.md` for future sessions?"

Only write to the adapter file if they confirm. Adapters are built from real failures — don't invent entries.

**Determine test file placement before writing:**

Grep for existing test files (`**/*.test.ts`, `**/*.test.tsx`, `**/*.spec.ts`) and check where they live relative to their source:
- All in `__tests__/` subdirectories → place new file at `<source-dir>/__tests__/<ComponentName>.test.<ext>`
- All colocated → place new file alongside the source as `<ComponentName>.test.<ext>`
- Mixed → ask once: "Your repo has both `__tests__/` and colocated tests — which should I use here?"
- No existing tests → default to `<source-dir>/__tests__/<ComponentName>.test.<ext>`

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

**Deliver:**

The complete test file. Then one line:
> "N tests written. Covers: [scenario names]. Run with: [test command]."

**Run and verify:**

Run only the new test file — do not run the full suite. Use the test runner
detected during init (recorded in `.testing-context.md`), scoped to this file.
Do not ask — just run it.

- All pass → report: "All N tests passing."
- Some fail → read the error output. Diagnose and fix silently. Re-run. Report once clean.
- Type errors → fix them. Re-run.
- If a fix requires a design change (wrong assumption about the component) → stop, show the error, explain what assumption was wrong, ask before changing.

Never claim success without having run the tests and seen them pass.

If you spotted gaps while writing, note them after:
> "I also noticed [X] isn't covered. Want to plan that next?"

---

## Step 5 — Update log

Always append one line to `.testing-log.md` at the project root (create it if it doesn't exist):

```
- [date]: [file/feature tested]. [One-line summary — include anything notable: regression caught, new pattern, sensitive area, or just "N tests written" if routine.]
```

If `.testing-log.md` exceeds 100 lines, trim the oldest entries down to 60 — no prompt needed, just trim silently.

`.testing-context.md` does not change here. It only changes during init or when a framework/tooling decision changes.
