# credo-debug — Debugging Credo Violations

Use this skill when Credo reports issues in your code that need to be understood and resolved.

## When to Use

- Running Credo (`mix credo`)
- Interpreting Credo output and prioritization
- Fixing Credo violations by category
- Understanding why a specific check is triggering

## Running Credo

```bash
mix credo                # all checks
mix credo --strict       # include strict categories
mix credo Category.Name # run specific category only
mix credo --all         # include ignored files
```

## Priority Categories

Credo organizes issues by priority (high to low):

1. **Correctness** — Bugs, security issues, code that will fail
2. **Design** — Refactoring opportunities, architectural concerns
3. **Readability** — Code clarity, naming, formatting
4. **Style** — Syntactic conventions, formatting preferences

**Always fix Correctness first, then Design, then Readability.**

## Common Checks

### Refactor.ModuleDependencies
Modules should not depend on modules that load infrastructure dependencies. Keep domain logic separate.

### Design.alias_without_use
When an alias is needed for a module, check if `use` would be more appropriate.

### Consistency.* 
Follow existing patterns in the codebase. Inconsistency is itself an issue.

### Readability.FunctionNames
Function names should follow Elixir conventions: `snake_case`, predicate functions end in `?`.

### Style.FunctionArity
Functions with many arguments should be refactored into a params map or broken into smaller functions.

## Fixing Violations

```bash
mix credo explain Path.to.File --check Design.FunctionArity
```

For auto-fixing style issues:
```bash
mix credo autocorrect
```

## Ignoring Code

For false positives, use `@moduledoc false` or `@dialyzer`:

```elixir
# credo:disable-for-next-line Credo.Check.Design.FunctionArity
def long_function_name(arg1, arg2, arg3, arg4, arg5, arg6), do: ...
```

Or disable for a file:
```elixir
# credo:disable-for-this-file Credo.Check.Category.CheckName
```

## Configuration

Credo config is in `.credo.exs`. Adjust thresholds and disabled checks there, but prefer fixing issues over disabling checks.

## MCP Tools

- `mcp_tidewave_get_docs` — look up module/function docs to understand intended behavior
- `mcp_tidewave_get_source_location` — find source of the violation

## Anti-patterns

- Do not disable checks globally without understanding why the issue exists
- Do not ignore Correctness issues — they often indicate real bugs
- Do not mass-disable checks in `.credo.exs` to make CI pass
