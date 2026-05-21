# Behavioral Theory — Why We Test and How

## The two purposes of frontend testing

**1. Catch regressions before users do.**
Encode what the user should experience so that any code change breaking that experience fails a test before reaching production. This is the primary purpose.

**2. Discover bugs the codebase already has.**
Writing tests forces deliberate exercise of code paths under controlled conditions that production never creates. Real bugs surface. This value is separate from regression prevention.

A test that serves neither purpose shouldn't exist.

## The core principle

> "The more your tests resemble the way your software is used, the more confidence they give you."
> — Testing Library guiding principle

A test should describe a user scenario, perform a real interaction, and assert something the user can observe. If you remove the interaction or the observable assertion, you remove the confidence.

## The mental model — Testing Trophy

```
        [ E2E ]           ← small, critical journeys only
   [ Integration ]        ← biggest investment
  [     Unit     ]        ← pure functions only
[ Static Analysis ]       ← TypeScript, ESLint
```

**Unit tests:** pure functions — calculators, validators, formatters, utilities. No UI, no rendering. Many edge cases. Fast.

**Integration tests:** UI components + real services + real stores, with only HTTP mocked. Test a flow: user action → service → store → observable outcome. This is where most FE testing value lives.

**E2E tests:** full user journey in a real browser. Reserve for 3-5 critical flows where integration tests can't reach. Expensive to maintain.

**Static analysis:** TypeScript and ESLint. Free regression prevention that runs constantly.

## The has-UI decision rule

```
Does this have UI?
│
├── No (pure function / utility / service with no rendering)
│   → Unit test. Input → output. Many cases. No rendering.
│
└── Yes (component / page / flow)
    → Integration test. User action → observable outcome.
       Mock only HTTP. Use real services, real stores.
```

## What "observable outcome" means

Prefer in this order:
1. Text the user reads (`screen.getByText(...)`, `expect(el.textContent).toContain(...)`)
2. Element present or absent based on meaningful state
3. Enabled / disabled state + behavioral proof (click actually blocked)
4. Store or state value that directly drives what renders
5. Exact API payload when the contract matters to correctness

Avoid:
- CSS class names that could change on refactor without breaking behavior
- Internal state that never reaches the user
- Mock call counts without any outcome assertion

## Accessibility

Accessibility testing is not optional. For applications operating in Europe, the European Accessibility Act (EAA, 2025) makes it a legal requirement.

At minimum: run `axe-core` against checkout-critical components (forms, buttons, payment flows). A test that asserts no accessibility violations is a real behavioral test — it asserts that a screen reader user can complete the flow.

## What a good test looks like from the outside

You should be able to read a test name and know:
- **What** is being tested
- **Under what condition**
- **What the user observes as a result**

`"phone input — when fewer than 10 digits — shows format error and blocks submit"` — good.
`"renders correctly"` — says nothing.
`"does not throw"` — proves nothing.
