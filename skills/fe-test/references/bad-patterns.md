# Bad Patterns — Never Write These

Five critical patterns that produce tests with false confidence. Check every test against this list before delivering.

---

## Pattern 1: Smoke assertion

**What it looks like:**
```ts
expect(() => render(Component)).not.toThrow();
expect(container).not.toBeNull();
expect(element).toBeInTheDocument(); // as the ONLY assertion
```

**Why it's bad:** Proves the component didn't crash. Says nothing about whether it works correctly. Passes even when the feature is completely broken.

**Replace with:** A real interaction + observable outcome.
```ts
await fireEvent.click(submitButton);
expect(screen.getByText('Please enter a valid email')).toBeInTheDocument();
```

---

## Pattern 2: Placeholder

**What it looks like:**
```ts
expect(true).toBe(true);
// TODO: add real assertion
```

**Why it's bad:** This is a lie. The test passes but asserts nothing. It inflates test count and coverage while providing zero protection.

**Replace with:** A real assertion or delete the test entirely.

---

## Pattern 3: Mock-call-only

**What it looks like:**
```ts
await fireEvent.click(button);
expect(mockApiCall).toHaveBeenCalled(); // nothing else
```

**Why it's bad:** Proves the mock was invoked. Doesn't prove the user saw success, the store updated correctly, or the UI responded. The feature could show an error to the user and this test still passes.

**Replace with:** Assert on what the user observes as a result of the call.
```ts
await fireEvent.click(button);
await waitFor(() => expect(screen.getByText('Order placed')).toBeInTheDocument());
```

---

## Pattern 4: Machine-specific path

**What it looks like:**
```ts
vi.mock('/Users/john/projects/my-app/src/Components/Button.svelte', ...);
vi.mock('C:\\Users\\jane\\repos\\app\\src\\Button.svelte', ...);
```

**Why it's bad:** Breaks on every machine except the one that wrote it. The test passes locally and fails in CI and on every colleague's machine.

**Replace with:** A path relative to the test file.
```ts
vi.mock('../Button.svelte', ...);
```

---

## Pattern 5: Loose rejection

**What it looks like:**
```ts
await expect(someAsyncFn()).rejects.toBeTruthy();
await expect(someAsyncFn()).rejects.toBeDefined();
```

**Why it's bad:** Passes on any rejection — including the wrong error, an unrelated throw, or a test setup mistake. It doesn't verify that the right failure happened.

**Replace with:** Match the actual rejection shape.
```ts
await expect(someAsyncFn()).rejects.toMatchObject({ statusCode: 400 });
// or
await expect(someAsyncFn()).rejects.toBe(expectedError);
```

---

---

## Pattern 6: Excessive mocking

**What it looks like:**
```ts
vi.mock('./ChildComponent');
vi.mock('./AnotherChild');
vi.mock('../utils/format');
vi.mock('../stores/OrderStore');
vi.mock('../services/ApiService');
```

**Why it's bad:** When everything is mocked, the test proves your mocks work — not that the feature works. A component can pass all its tests while being completely broken in practice because none of the real code ran.

**Replace with:** Mock only at the HTTP boundary. Use real stores, real utilities, real child components. Only stub a child when its import pulls in a native module or external dependency that makes the test impossible to run — not just because it's convenient.

```ts
// ✅ Mock the HTTP call. Let everything else be real.
vi.mock('common/services/ApiService', async () => await import('$test/mocks/ApiService'));
```

---

## Pattern 7: Testing library or framework behavior

**What it looks like:**
```ts
// Testing that fireEvent.click calls the onClick handler
expect(mockOnClick).toHaveBeenCalled();

// Testing that store.set() triggers a reactive update
store.set('upi');
expect(get(store)).toBe('upi');

// Testing that a router navigates when navigate() is called
expect(mockNavigate).toHaveBeenCalledWith('/success');
```

**Why it's bad:** The library or framework is already tested by its maintainers. You are paying maintenance cost to re-verify code you didn't write and can't change. These tests pass forever and catch nothing about your actual feature.

**Replace with:** Test your code's response to the user action — what the user sees as a result, not which internal function was invoked.
```ts
// Instead of: click called the handler
// Test: user sees the outcome of what should happen when they click
await fireEvent.click(submitButton);
expect(screen.getByText('Processing your order...')).toBeInTheDocument();
```

---

## Pattern 8: CSS class assertion without behavioral proof

**What it looks like:**
```ts
expect(button).toHaveClass('disabled');
expect(container).toHaveClass('is-loading');
expect(el).toHaveClass('active');
```

**Why it's bad:** Class names change freely on refactors. A class named `disabled` doesn't mean the button is actually disabled — it might just look grey. A class rename breaks the test even when the behavior is identical. The test is coupled to styling decisions, not user experience.

**Replace with:** Assert the actual behavior the class was meant to produce.
```ts
expect(button).toBeDisabled();

// Or prove the interaction is blocked:
const before = get(store_triggerContinueFunction);
await fireEvent.click(button);
expect(get(store_triggerContinueFunction)).toEqual(before);
```

**When a CSS class assertion is acceptable:** only when the class directly drives user-visible behavior (e.g. controls `pointer-events` or `visibility`) AND a behavioral assertion accompanies it — the class check is secondary evidence, not the sole assertion.

---

## Ratio check

If more than half the tests in a file have no DOM or user-visible assertion, pause and confirm:

> "Most tests here assert on internal state rather than what the user sees. For a pure service test this is intentional — confirm, or should we adjust the scenarios?"

This is not a hard block. It's a signal worth surfacing.

---

## When a pattern is acceptable

- `not.toThrow()` is acceptable when the test is explicitly about defensive behavior on bad input and the bad-input path is the thing being tested. Name it clearly: `"accepts null without crashing"`.

If in doubt: does removing this assertion make the test less useful? If no, remove it.
