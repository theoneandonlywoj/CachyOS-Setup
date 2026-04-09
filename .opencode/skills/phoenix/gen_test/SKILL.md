# gen_test — Generate and Write Tests

Use this skill when writing tests for Elixir modules, Phoenix contexts, LiveViews, or any test file following ExUnit conventions.

## When to Use

- Creating new test files
- Writing ExUnit tests for Elixir modules
- Testing Phoenix contexts
- Writing LiveView tests

## Test Structure

```elixir
defmodule App.AccountsTest do
  use App.DataCase, async: true
  alias App.Accounts

  describe "users" do
    test "create_user/1 with valid data succeeds" do
      attrs = valid_user_attrs()
      assert {:ok, user} = Accounts.create_user(attrs)
      assert user.email == attrs.email
    end
  end
end
```

## async: true

Use `async: true` when tests are truly independent and do not share state.

## start_supervised!/1

**Always use `start_supervised!/1`** for starting processes in tests:

```elixir
{:ok, pid} = start_supervised!(MyApp.DynamicSupervisor)
```

## Process Synchronization

**Avoid `Process.sleep/1` and `Process.alive?/1`.**

Wait for process death:
```elixir
ref = Process.monitor(pid)
assert_receive {:DOWN, ^ref, :process, ^pid, :normal}
```

Synchronize state:
```elixir
_ = :sys.get_state(pid)
```

## LiveView Testing

```elixir
import Phoenix.LiveViewTest

{:ok, view, html} = live(conn, "/path")
assert render(view) =~ "content"
render_submit(view, :save, %{user: %{name: "test"}})
render_change(view, :validate, %{user: %{name: ""}})
```

Always reference element IDs with `has_element?/2` and `element/2`.

## Context Testing

```elixir
setup do
  {:ok, user: user_fixture()}
end

test "get_user!/1 returns user", %{user: user} do
  assert Accounts.get_user!(user.id).email == user.email
end
```

## Testing Changesets

```elixir
test "changeset with invalid attrs returns error" do
  changeset = User.changeset(%User{}, @invalid_attrs)
  refute changeset.valid?
end
```

## Mocking

Avoid mocking when possible. Use protocols and behaviours for testability.

```elixir
defmodule MockHTTP do
  @behaviour HTTPClient
  def get(url), do: {:ok, %{status: 200, body: "mocked"}}
end
```

## MCP Tools

- `mcp_tidewave_project_eval` — evaluate test expressions in running app context
- `mcp_tidewave_execute_sql_query` — verify DB state after tests

## Anti-patterns

- Do not use `Process.sleep/1` for waiting — use proper assertions
- Do not test raw HTML — use selector-based assertions
- Do not mock Ecto repos directly — use `Ecto.Adapters.SQL.Sandbox`
- Do not share mutable state between tests without `setup`
