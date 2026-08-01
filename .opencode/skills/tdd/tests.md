# Good Test Examples

Tests verify behavior through public interfaces, not implementation details.

## Good example

```typescript
it("allows a user to checkout with a valid cart", () => {
  const cart = addItem(emptyCart(), "toothbrush", 2);
  const result = checkout(cart, validPayment());
  expect(result.status).toBe("confirmed");
});
```

This test says what capability exists and survives refactors.

## Bad example

```typescript
it("calls the payment adapter with the right arguments", () => {
  const adapter = jest.fn();
  checkout(cart, adapter);
  expect(adapter).toHaveBeenCalledWith(expectedArgs);
});
```

This test is implementation-coupled. It breaks if you rename the adapter.

## Rules

- Name tests like specifications.
- Expected values must come from an independent source: a literal, a worked example, the spec.
- One seam, one test, one implementation per cycle.
