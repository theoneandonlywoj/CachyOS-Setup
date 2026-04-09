# dialyzer-debug — Debugging Dialyzer Warnings

Use this skill when Dialyzer produces warnings or errors that need to be investigated and resolved.

## When to Use

- Interpreting Dialyzer output (`mix dialyzer`)
- Understanding why Dialyzer thinks a function will fail
- Fixing type specification issues
- Managing .plt files

## Running Dialyzer

```bash
mix dialyzer
mix dialyzer --format json  # for machine-readable output
mix dialyzer --no-check     # faster, skips deps check
```

## Common Warning Types

### Function argument type mismatch
```
FunctionName.module/arity will fail if
  first argument is not 'ok' | :error
```

Usually means you need a guard or a better type specification.

### Contract_supertype
```
The return type specification and
the success typing are not consistent
```

Means your `@spec` is narrower than what the function actually returns.

### Unknown functions
```
Unknown functions - Module.function/arity
```

Function not defined or not visible. Check imports and aliases.

## Fixing vs Suppressing

**Prefer fixing over suppressing.**

If a warning is a false positive, add a type specification to guide Dialyzer:

```elixir
@spec my_function(nonempty_mixed()) :: :ok | :error
def my_function(arg), do: ...
```

To suppress a known-acceptable warning, use `@dialyzer` attribute:

```elixir
@dialyzer {:nowarn_function, my_function: 1}
```

## PLT Files

PLT (Persistent Lookup Table) caches type information. If you see stale warnings after updating deps:

```bash
mix dialyzer --force-build
```

## Dialyxir Mix Tasks

```bash
mix dialyzer                      # analyze
mix dialyzer --plt                # build PLT
mix dialyzer --force              # rebuild PLT
mix dialyzer --no-check           # skip deps check (faster)
```

## Elixir Type Specs

Use standard types and user-defined types:

```elixir
@type user :: %User{id: integer(), email: String.t()}
@type create_attrs :: %{required(:email) => String.t(), optional(:name) => String.t()}

@spec create_user(create_attrs()) :: {:ok, user()} | {:error, Ecto.Changeset.t()}
```

## MCP Tools

- `mcp_tidewave_get_docs` — look up types for stdlib modules
- `mcp_tidewave_get_source_location` — find where functions are defined to add specs

## Anti-patterns

- Do not blindly suppress warnings without understanding them
- Do not use `@spec` that contradicts actual return values
- Do not ignore contract warnings — they often indicate real bugs
