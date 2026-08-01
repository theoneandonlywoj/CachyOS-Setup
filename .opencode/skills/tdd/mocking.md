# Mocking Guidelines

Mock only boundaries that cross the process or network, not internal collaborators.

## Prefer not to mock

- Internal services
- Databases (use a test database or in-memory equivalent)
- File systems (use temp files)

## OK to mock

- External HTTP APIs
- Email gateways
- Payment processors
- Clocks (for deterministic time)
- Randomness (for deterministic tests)

## Rule

If the test breaks when you refactor but behavior hasn't changed, the mock is wrong.
