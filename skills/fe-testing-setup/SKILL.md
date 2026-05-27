---
name: fe-testing-setup
description: One-time frontend testing setup for a new codebase. Use when starting work in a project with no tests, when asked about test configuration, or to scan and profile a repo before a first testing session. Run this once per project — fe-test handles everything after.
---

You are setting up the testing foundation for this codebase. Run this once.
After this, use `/fe-test` for all test writing.

## Step 1 — Scan silently

Read these without asking anything yet:
- `package.json` — framework, existing test runners, test utilities
- Any config files: `vitest.config.*`, `jest.config.*`, `playwright.config.*`, `cypress.config.*`
- 2-3 existing test files if present — understand current pattern quality
- Project name from `package.json` or folder name

## Step 2 — Branch on what you found

### Testing already set up

Report briefly:
```
Testing stack:
- Framework: [X]
- Test runner: [X]
- Utilities: [X]
- Existing tests: [N files, ~N tests]
- Pattern quality: [behavioral / smoke / mixed — one honest line]
```

Ask:
> "What would you like to do?
> 1. Write new test cases for a component or feature
> 2. Review and improve existing tests
> 3. Add a missing layer (accessibility, E2E, visual)"

If they choose 1: tell them to use `/fe-test` from now on.

### No testing set up

Use your knowledge of testing frameworks to generate 2-3 options for the
detected framework. Then search online to check for recent updates.

For each option:
```
Option N — [Stack name]
What: [One sentence]
Good for: [When to pick this]
Trade-off: [One honest downside]
```

End with a clear recommendation:
> "My recommendation: Option [N] — [one honest reason]."

Wait for their choice. Help set up the chosen stack step by step.

## Step 3 — Write the repo context file

Before writing the file, ask two more questions:

> "Two quick things before I set up the context file:
> 1. What does this product do for users? One sentence.
> 2. What are the 3-5 most critical user flows — the ones where a bug would hurt users most?"

Wait for both answers. Then create `.testing-context.md` at the project root
using those answers:

```markdown
# Testing Context — [project name]

## What this product does
[Answer from question 1 above]

## Critical user flows
[Answers from question 2 above]

## Testing decisions
- Framework: [X]
- Test runner: [X]
- Pattern quality found: [behavioral / smoke / mixed]

## Sessions
- [today's date]: Setup session.
```

This file lives in the repo root — commit it so the whole team benefits.
`/fe-test` reads it at the start of every session and appends to it when done.
Never overwrite it, always append to the Sessions section.

## Gotchas

- If you detect a monorepo, ask which package to profile before writing the context file.
- If existing tests are mostly smoke-style, say so plainly — it's useful information.
- If you can't determine the framework confidently, ask before guessing.
- After this skill completes, all future work goes through `/fe-test`.
