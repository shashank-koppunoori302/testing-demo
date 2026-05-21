# Quality Gates — Good Patterns to Follow

Three anchors. Every good frontend test has at least one of these.

---

## Anchor 1: User-visible text or state as the assertion target

The user reads text. The user sees things appear and disappear. The user experiences enabled or disabled controls. Test those.

```ts
// Error message appears
expect(screen.getByText('Please enter a 10-digit number')).toBeInTheDocument();

// Success state renders
expect(screen.getByText('Order placed successfully')).toBeInTheDocument();

// Field disappears when not applicable
expect(screen.queryByLabelText('GST Number')).not.toBeInTheDocument();
```

**The question to ask:** If I showed this assertion to a product manager, would they understand what it's protecting?

---

## Anchor 2: Interaction before assertion

A test that only renders and asserts is describing the initial state. A test that performs an action and then asserts is protecting behavior.

```ts
// User submits an empty form
await fireEvent.submit(form);
expect(screen.getByText('Name is required')).toBeInTheDocument();
expect(get(store_disableContinueButton)).toBe(true);

// User clicks a disabled button — nothing happens
const before = get(store_triggerContinueFunction);
await fireEvent.click(disabledButton);
expect(get(store_triggerContinueFunction)).toEqual(before);
```

**The rule:** If there is no `fireEvent`, `userEvent`, or `store.set(...)` that simulates a condition change, ask whether the test is actually about behavior or just initial rendering.

---

## Anchor 3: Rule of Three in the test name

Every test name answers three questions:
1. **What** is being tested
2. **Under what condition**
3. **What the user observes**

```
// Good
"phone input — when fewer than 10 digits — shows format error and blocks submit"
"coupon field — when invalid code entered — shows rejection message and clears field"
"payment button — when store_disableContinueButton is true — ignores click"

// Bad
"renders correctly"
"works as expected"
"handles the error case"
"does not throw"
```

The name should be readable as a specification. If a future developer reads only test names, they should understand the feature's contract.

---

## One more: exact payloads on money paths

When a test covers a service that constructs API payloads for orders, payments, discounts, or addresses — assert on the exact payload, not just that the function was called.

```ts
expect(mockPostCall).toHaveBeenCalledWith(
  expect.objectContaining({
    url: '/api/orders/create',
    body: expect.objectContaining({
      payment_method: 'upi',
      amount: 1499,
      currency: 'INR',
    }),
  })
);
```

Wrong amount, wrong method, wrong currency — a test that only checks `toHaveBeenCalled()` misses all of these.
