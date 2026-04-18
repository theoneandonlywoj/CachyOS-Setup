---
name: test
description: Run the project test suite. Use when running mix test, ExUnit, or validation tests.
---

# test — Run Project Test Suite

Use when you need to run tests to verify functionality or validate changes.

## When to Use

- Before committing changes
- After modifying business logic
- When fixing bugs to verify the fix
- CI/CD pipeline execution

## Running Tests

### Elixir/ExUnit

```bash
mix test                  # all tests
mix test --trace         # verbose per test output
mix test test/path_test.exs  # specific file
mix test --seed 12345   # randomize with seed for reproducibility
mix test --max_failures 5  # stop after N failures
```

### Running by Tag

```bash
mix test --only focus: true  # run tests tagged :focus
mix test --exclude integration  # exclude tests by tag
```

### Fish Script Validation (if applicable)

```bash
make soft-test
```

## Test Output Interpretation

- `.` — test passed
- `F` — test failed
- `E` — test error
- `P` — test skipped (pending)

## Failed Tests

When a test fails:
1. Read the failure message carefully
2. Check the stack trace for the exact line
3. Use `--trace` to see detailed per-step output
4. Run the specific file to isolate the issue

## Anti-patterns

- Do not skip tests to make CI pass
- Do not commit without running the full suite
- Do not ignore flaky tests — fix or mark them
