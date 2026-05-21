# Global Learnings — Frontend Testing

Cross-session patterns that apply to any repo. Updated by fe-test-learn after sessions where something non-obvious was discovered.

---

## Coverage metrics are not interchangeable
**Decision:** Triage by branches + uncovered lines. Not by funcs% or lines% alone.
**Why:** Lines% measures code that ran. Branch% measures paths exercised. Funcs% under V8+Svelte4 is instrumentation noise — files with real tests show 0% because compiled closures aren't mapped back to source functions.

---

## Coverage numbers are a lagging signal, not a goal
**Decision:** Never use a coverage target as the primary reason to write a test.
**Why:** Tests written to lift coverage rather than protect user flows produce false confidence. High coverage can coexist with broken features if the tests aren't behavioral.

---

## Discovery before code — always
**Decision:** Ask questions about user impact before reading the implementation.
**Why:** The file shows you what the code does. The human knows what matters to the user. You need both. The human's context is irreplaceable and can't be inferred from reading the source.

---

## Smoke tests accumulate silently
**Decision:** Flag any test whose primary or only assertion is `not.toThrow()`, `toBeInTheDocument()` alone, or `expect(true).toBe(true)`.
**Why:** Smoke tests pass when features are broken. They look like coverage but provide no regression protection. They accumulate fastest when tests are written to meet a metric.

---

## Marker stubs for layout decisions, not behavior
**Decision:** Use marker stubs (with data-testid) to prove which child mounted. Use real (un-stubbed) children to test behavior the parent drives through props or events.
**Why:** If a parent stubs all children with EmptyComponent, the test can't prove any of the parent's real behavior — only that it rendered without crashing.

---

## beforeAll mock setup gets wiped
**Decision:** Always seed mock return values in `beforeEach`, never `beforeAll`.
**Why:** `vi.resetAllMocks()` runs globally in `afterEach`. `beforeAll` runs once and its setup is wiped before test 2 runs. Tests that pass in isolation fail in sequence.

---

## Machine-specific paths break portability
**Decision:** Never use absolute paths in `vi.mock()`. Always use relative paths from the test file.
**Why:** `/Users/someone/project/src/Component.svelte` only works on one machine. It breaks in CI and on every colleague's machine silently — tests pass locally, fail everywhere else.

---

## Parallel agent dispatch needs human visibility before scaling
**Decision:** Show one example test before dispatching multiple agents in bulk.
**Why:** If the example is weak, multiplying it across 5 files multiplies the weakness. Seeing one test lets the human course-correct before the problem is at scale.

---

## Svelte store subscriber fires synchronously during .set()
**Decision:** When testing Svelte components, be aware that a store subscriber updates the local reactive variable during the `.set()` call — before the next line executes.
**Why:** This means if a function reads `!localVar` twice (once to pass to `.set()`, once for another call), the second read sees the post-subscriber value, not the pre-set value. Can cause assertions to look inverted.

---

## Integration tests > unit tests for UI components
**Decision:** For components that own event handlers, lifecycle hooks, or store-driven reactive logic — write integration tests (real services, only HTTP mocked) not unit tests (everything mocked).
**Why:** Unit tests with fully mocked dependencies test that your mocks work, not that the component works. A component can pass all its unit tests while being completely broken in practice.

---

## Human review belongs at the start, not throughout
**Decision:** Front-load the human checkpoint to scenario approval. After that, rules govern execution.
**Why:** If humans must review every individual test, they become the quality bottleneck. If they only review the scenario direction (what to test and why), they stay in control of what matters without reviewing implementation details.

---

## The three-question filter for every test
**Decision:** Before including a test, confirm: (1) Would this catch a real user or checkout regression? (2) Does it assert something observable? (3) Would you still want it if coverage numbers were hidden?
**Why:** If any answer is no, the test is serving coverage, not confidence. Coverage is a side effect of good tests, not the goal.

---

## Tests surface source bugs — log them separately
**Decision:** When writing tests reveals a bug in the source (not in the test), document it separately and don't fix it in the same branch.
**Why:** Mixing source bug fixes into a testing push makes PRs harder to review. Tests that pin buggy behavior should note the bug with a comment. The fix belongs in a separate commit with owner review.

---

## Contract testing — skip for coordinated teams
**Decision:** Don't invest in Pact contract testing for teams where FE and BE are coordinated and API changes don't happen silently.
**Why:** Contract testing solves the "BE changed the API without telling FE" problem. In 6+ years of industry experience, this problem is solved by coordination, not tooling. The overhead isn't worth it for most teams.

---

## Accessibility is not optional
**Decision:** Treat accessibility testing as a required layer, not an optional enhancement.
**Why:** The European Accessibility Act (EAA) has been in force since 2025. For apps operating in Europe, this is a legal compliance requirement. For all apps, it's a real regression class: keyboard-only and screen reader users are real users.

---

## Analytics-only tests — delete them
**Decision:** If the only assertion is `expect(logEvent).toHaveBeenCalled()`, delete the test.
**Why:** Analytics fan-out is a relay — testing it mirrors the implementation 1:1. It tells you the relay fired, not that anything meaningful happened for the user. Exclude analytics files from coverage instead of padding tests for them.

---

## Mount + unmount catches bugs production never sees
**Decision:** Write at least one mount-and-unmount test per component that has subscriptions or cleanup logic.
**Why:** A component that never unmounts in production can ship with a broken `onDestroy`. Render-only tests miss it. Unmounting in a test calls `onDestroy` and surfaces broken unsubscribe patterns. Real example: `BottomSheet.svelte` had `unsubscribe = store.set(...)` — `set()` returns void, so unsubscribe was undefined. Production never caught it because the component never unmounted. A test did on first run.

---

## Stubbed children need their own test file
**Decision:** If a parent test stubs a child component, that child needs its own dedicated test file.
**Why:** The parent's stub covers lines (the file loaded) but not behavior (nothing runs). Any child with event handlers, lifecycle hooks, or store-driven reactive logic is invisible to the test suite unless it has its own file that actually invokes it.

---

## Exclude inert files from the coverage denominator
**Decision:** Exclude analytics relays, environment URL maps, store declarations, icon SVGs, loading skeletons, and decorative components from coverage tracking.
**Why:** These files have no business logic to test. Including them in the denominator creates a false branch gap that pressure-tests you into writing meaningless tests. Excluding them is honest accounting. Padding tests for them is gaming the metric.

---

## Dead code removal lifts branch% for free
**Decision:** When you find stale A/B experiments, unused feature flags, or dead branches — remove the code, don't test it.
**Why:** Dead code sits in the coverage denominator with no tests against it. Each removed dead branch reduces the gap without writing a single test. Testing dead code produces tests that would never fail in production.

---

## CI threshold: set on lines, not branches
**Decision:** Set the CI coverage gate against line coverage (target ~80%), not branch coverage.
**Why:** Branch% on a UI codebase naturally plateaus around 60-65% because conditional UI rendering creates combinatoric branch explosion. Setting a branch gate forces low-value tests to cover cosmetic display conditions. Track branch% as a signal, but gate on lines.

---

## No file-header comments or triage status in test files
**Decision:** Test files should have `// @ts-nocheck` at the top and nothing else above the imports.
**Why:** File-level summaries ("Behaviour tests for X.svelte"), triage status ("P0 in coverage triage, Br 18% before/60% after"), and stub annotations ("Heavy children — stub X") add noise that rots as the code evolves. The test names are the documentation. Keep only `// @ts-nocheck` at the top.

**Specifically banned:**
- "Behavior tests for X.svelte. Surface: …"
- "P0 in coverage triage"
- "Br 18% before / 60% after"
- Bullet lists describing what each test will exercise
- Restating what an assertion checks ("// last 4 of card")
