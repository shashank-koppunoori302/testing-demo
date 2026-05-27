---
name: fe-test-learn
description: Save a testing decision or learning to memory. Use when you want to explicitly remember a decision, pattern, or lesson outside of a test-writing session. The fe-test pipeline handles memory automatically at the end of each session — use this skill only when you want to save something ad-hoc mid-session or outside the pipeline.
---

You are saving a specific learning or decision to memory.

## When this skill is useful

- You made a decision mid-session that the pipeline didn't capture
- You want to save something from a code review or discussion
- You discovered a pattern worth remembering outside a test run
- You want to manually trim or update the learnings file

**The `/fe-test` pipeline already asks about memory at the end of each session.
This skill is for everything else.**

## Step 1 — Understand what to save

Ask if not already clear:
> "What should I remember? Describe the decision or learning."

Wait for their answer.

Does this apply to all repos (general principle) or just this one (repo-specific)?
- General → write to `.agents/skills/fe-test/knowledge/global-learnings.md`
- Repo-specific → write to `.testing-context.md` at the project root (under Testing decisions)

## Step 2 — Check for duplicates

Read the target file. If a similar entry exists, update it — don't add a new one.

## Step 3 — Write

```markdown
## [Title — max 8 words]
**Decision:** [One sentence — what was decided or learned]
**Why:** [One sentence — the reason that makes this non-obvious]
```

Append to the correct file.

## Step 4 — Size check

Count entries in the file. If over 30:
> "The learnings file has 30+ entries. Want to review and trim?"

Do not auto-delete. Prompt the user.

## Trimming

If the user wants to trim, show all entries and ask which to remove or merge.
Aim to keep the most actionable, most universal, and most non-obvious entries.
Remove entries that are obvious, repo-specific in a global file, or superseded
by a better entry.
