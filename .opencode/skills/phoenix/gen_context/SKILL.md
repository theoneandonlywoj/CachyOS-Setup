# gen_context — Generate Phoenix Contexts

Use this skill when you need to create a new Phoenix context (a module that encapsulates business logic and data access), or add functionality to an existing context.

## When to Use

- Creating a new feature area (e.g. `mix phx.gen.context Accounts User users ...`)
- Adding a new context module for a domain concept
- Deciding whether something belongs in a context vs a schema

## Command

```bash
mix phx.gen.context ContextName SchemaName table_name field:type field:type
```

## Context vs Schema Separation

- **Schema** — Data structure, field definitions, Ecto-specific logic (changesets)
- **Context** — Business logic, data access, public API, cross-schema operations

## Naming Conventions

- Contexts: CamelCase singular noun (`Accounts`, `Billing`, `Content`)
- Functions: snake_case (`list_users`, `create_user`, `get_user!`)
- Use `!` for functions that raise on not found (`get_user!`)
- Do not raise in functions that return `nil` on not found

## Filtering with current_scope

When using `phx.gen.auth`, filter queries by `current_scope.user`:

```elixir
@spec list_posts(Scope.t()) :: [Post.t()]
def list_posts(%Scope{} = current_scope) do
  Post
  |> where(user_id: ^current_scope.user.id)
  |> Repo.all()
end
```

Pass `current_scope` as first argument to all context functions that access user-specific data.

## Preloading Associations

Always preload when accessed in templates:

```elixir
@spec get_user!(integer()) :: User.t()
def get_user!(id) do
  User
  |> Repo.get!(id)
  |> Repo.preload(:posts)
end
```

## Changeset Pattern

```elixir
@spec create_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
def create_user(attrs) do
  %User{}
  |> User.registration_changeset(attrs)
  |> Repo.insert()
end
```

## MCP Tools

- `mcp_tidewave_get_ecto_schemas` — list schemas to understand existing data model
- `mcp_tidewave_execute_sql_query` — inspect data for debugging
- `mcp_tidewave_project_eval` — test context functions in running app

## Anti-patterns

- Do not put schema-specific Ecto logic in contexts (belongs to schema)
- Do not duplicate context functions across multiple contexts
- Do not access `current_user` directly in contexts — use `current_scope.user`
