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

## Ratio check

If more than half the tests in a file have no DOM or user-visible assertion, pause and confirm:

> "Most tests here assert on internal state rather than what the user sees. For a pure service test this is intentional — confirm, or should we adjust the scenarios?"

This is not a hard block. It's a signal worth surfacing.

---

## When a pattern is acceptable

- `not.toThrow()` is acceptable when the test is explicitly about defensive behavior on bad input and the bad-input path is the thing being tested. Name it clearly: `"accepts null without crashing"`.
- Class-name assertions are acceptable when the class drives meaningful user-visible behavior (e.g. a CSS class that controls opacity + pointer-events for a disabled button) AND a behavioral assertion accompanies it.

If in doubt: does removing this assertion make the test less useful? If no, remove it.
