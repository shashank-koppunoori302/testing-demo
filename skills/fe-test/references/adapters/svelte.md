# Adapter: Svelte 4 + Vitest + Testing Library

Framework-specific patterns for Svelte 4 with Vitest 2 and @testing-library/svelte.

---

## Rendering

```ts
import { render, fireEvent, waitFor, screen } from '@testing-library/svelte';
import Component from '../Component.svelte';

const { container } = render(Component, {
  props: { foo: 'bar' },
});
```

**Critical:** `vitest.config.mts` must include `svelteTesting()` plugin. Without it, `onMount` and `onDestroy` silently no-op in tests. Symptom: `unsubscribe is not a function` at cleanup time.

---

## Querying — order of preference

| Use | When |
|---|---|
| `screen.getByRole('button', { name: /Submit/i })` | Anything with a role |
| `screen.getByLabelText(/Pincode/)` | Form inputs |
| `screen.getByText(/Order placed/)` | Visible copy |
| `container.querySelector('[data-testid="foo"]')` | When role/text not viable |
| `container.querySelector('.class-name')` | Last resort — avoid |

Use `data-testid` over CSS class selectors. Class selectors break on styling refactors.

---

## Async — always await

```ts
await fireEvent.click(button);              // flushes microtasks
await waitFor(() => expect(...).toBe(...)); // re-runs until passes or times out
```

`fireEvent` in Svelte TL is async — always `await`. Without it, reactive blocks haven't run by assertion time.

---

## vi.mock — the hoist trap

`vi.mock` is hoisted above imports. Top-level variables referenced in the factory are `undefined` at hoist time.

```ts
// ❌ Broken
import { stub } from '$test/mocks/ApiService';
vi.mock('common/services/ApiService', () => ({ postCall: stub }));

// ✅ Correct — dynamic import inside factory
vi.mock('common/services/ApiService', async () => await import('$test/mocks/ApiService'));
import { mockPostCall } from '$test/mocks/ApiService'; // for assertions only
```

**Never use absolute paths in vi.mock.** Always relative from the test file:
```ts
vi.mock('../Button.svelte', async () => await import('../../test/stubs/EmptyComponent.svelte'));
```

---

## Mock reset — automatic, never manual

`vi.resetAllMocks()` runs globally in `afterEach`. Consequence:
- Set `mockX.mockResolvedValue(...)` inside `beforeEach` or the test body
- **Never** in `beforeAll` — gets wiped before test 2
- **Never** call `vi.resetAllMocks()` manually in your test file

---

## Svelte stores — real, never mocked

```ts
import { get } from 'svelte/store';
import { store_paymentMethod } from 'common/stores/OrderStore';

beforeEach(() => store_paymentMethod.set(null));

it('switches method', async () => {
  store_paymentMethod.set('upi');
  expect(get(store_paymentMethod)).toBe('upi');
});
```

`store.set()` returns `void`. Never write `unsubscribe = store.set(...)` — `unsubscribe()` later crashes silently.

**Gotcha:** Svelte's store subscriber fires synchronously during `.set()`. If your component reads `!localVar` both inside `.set()` and immediately after, the local variable has already been mutated by the subscriber. This causes the second read to return the opposite value. Capture the value before setting if you need both reads to be consistent.

---

## Stubbing child components

Stub a child only when its import makes the test impossible to run — a native canvas
module, a heavy third-party SDK, an unpatchable global. Do not stub children just
because they're large or have their own logic; that kills the parent-child interaction
the test is supposed to cover.

When stubbing is genuinely needed:

```ts
vi.mock('./HeavyChild.svelte', async () =>
  await import('../../../../test/stubs/EmptyComponent.svelte'));
```

`EmptyComponent.svelte` — accepts any props, renders nothing. Svelte will log `was created with unknown prop` for each prop passed to the stub — suppress this in `setup.ts`.

For tests where you need to prove which child mounted (layout decisions), use a
marker stub with a `data-testid` instead of EmptyComponent.

---

## File header — required

```ts
// @ts-nocheck
```

First line of every test file. Silences VS Code's inferred-project mode (which doesn't pick up the test tsconfig). Actual type checking still runs via `npx tsc --noEmit -p tsconfig.test.json`.

---

## Known gotchas

| Symptom | Cause | Fix |
|---|---|---|
| `onMount` never fires | Missing `svelteTesting()` plugin | Add to `vitest.config.mts` plugins |
| `unsubscribe is not a function` | `unsubscribe = store.set(...)` in source | `set()` returns void — fix the source |
| Mock not intercepting | Using absolute path in `vi.mock()` | Use relative path from test file |
| Mock history persists between tests | Manual `vi.resetAllMocks()` override | Remove manual reset; setup.ts handles it |
| `toBeInTheDocument` not recognized | Wrong jest-dom import | Use `import '@testing-library/jest-dom/vitest'` |
| Test passes locally, fails in CI | Store state leaked from prior test | Reset stores in `beforeEach` |
| `funcs%` shows 0% despite real tests | Svelte 4 V8 instrumentation noise | Don't triage by funcs%. Use branches + uncovered lines. |

---

## setup.ts — centralise all jsdom stubs here, not per-test

```ts
import '@testing-library/jest-dom/vitest';   // /vitest subpath, NOT plain jest-dom
import { cleanup } from '@testing-library/svelte';
import { afterEach, vi } from 'vitest';

// jsdom-unimplemented APIs — stub once, silence everywhere
window.focus = () => {};
window.blur = () => {};
window.open = () => null as any;
window.scrollTo = () => {};
HTMLCanvasElement.prototype.getContext = () => null as any;
Element.prototype.scrollIntoView = () => {};

// Suppress non-actionable console noise from stubs and jsdom
const SUPPRESS = [
  'was created with unknown prop',      // Svelte stub stand-ins receive parent props
  'received an unexpected slot',        // stubs don't declare default slot
  'Failed to start camera',             // camera permission denial in Selfie tests
  'Could not parse CSS stylesheet',     // jsdom CSS parser limitation
  'Not implemented: HTMLCanvasElement', // jsdom canvas stub
];
const filter = (orig: (...a: any[]) => void) => (...args: any[]) => {
  const first = typeof args[0] === 'string' ? args[0] : args[0]?.message ?? '';
  if (SUPPRESS.some((s) => first.includes(s))) return;
  orig(...args);
};
console.warn = filter(console.warn.bind(console));
console.error = filter(console.error.bind(console));

afterEach(() => {
  cleanup();
  vi.resetAllMocks();
});
```

**Why central, not per-test:** `window.focus` and friends log "Not implemented" stderr that pollutes every test run. One stub block silences every test file. Per-test stubs create duplication and easy-to-miss noise.

---

## Canary test — validate mock contracts don't drift

Create `src/__tests__/setup.canary.test.ts`. It should:
1. Assert jest-dom matchers are loaded
2. Assert `vi.resetAllMocks()` fires between tests (not just assumed)
3. Walk every `test/mocks/<X>.ts` via the TS AST and assert it only exports names that the real source actually has

The third check catches the most expensive failure mode: a mock exports a function that was renamed or removed from the source. Tests keep passing. Production breaks.

```ts
// Minimal example of the mock-drift check:
import * as RealService from 'common/services/MerchantAPI';
import * as MockService from '$test/mocks/MerchantAPI';

it('mock exports only what the real source has', () => {
  const realKeys = Object.keys(RealService);
  const mockKeys = Object.keys(MockService).filter(k => !k.startsWith('mock'));
  mockKeys.forEach(key => {
    expect(realKeys).toContain(key);
  });
});
```

---

## vitest.config.mts — required onwarn filter

```ts
svelte({
  onwarn: (warning, handler) => {
    const ignored = ['css-unused-selector', 'css_unused_selector', 'unused-export-let'];
    if (ignored.includes(warning.code) || warning.code.startsWith('a11y-')) return;
    handler?.(warning);
  },
})
```

Without this, CSS and a11y warnings from stubs pollute the test output.

---

## Coverage exclusion categories (for vitest.config.mts)

Exclude these from the coverage denominator — no business logic to test:

| Category | Example pattern |
|---|---|
| Analytics relays | `**/ForeignAnalytics.ts`, `**/EventService.ts` |
| Environment URL routing | `**/EnvironmentService.ts`, `**/ApiConfig.ts` |
| Type-only files | `**/Interfaces.ts`, `**/*.d.ts` |
| Store declarations | `**/stores/**` |
| Lazy-load skeletons | `**/lazy-load/**` |
| Pure visual assets | `**/*.svg` |
| Decorative components | `**/TermsAndConditions.svelte`, `**/TrustBanner.svelte` |
| Generic DOM utilities | `**/pannable.ts` |

Adding a comment per exclusion in the config prevents silent gaming later.

---

## Verification before commit

```bash
npm run validate                                # svelte-check (production types)
npx tsc --noEmit -p tsconfig.test.json          # test type-check
npm test                                        # all tests pass
```

All three must pass.
