---
name: gen-migration
description: Generate Ecto database migrations for schema changes. Use when adding tables, columns, indexes, or constraints.
---

# gen-migration — Generate Ecto Migrations

Use this skill when you need to create database migrations for schema changes, adding columns, creating tables, or modifying indexes.

## When to Use

- Adding a new table
- Adding/removing/modifying a column
- Creating or dropping indexes
- Altering table constraints
- Any database schema change

## Command

```bash
mix ecto.gen.migration name_using_underscores
```

## Conventions

- Migration names use underscores, not CamelCase: `add_email_to_users` not `addEmailToUsers`
- Each migration has `change/0` (auto-directional) or explicit `up/0` + `down/0`
- Use `timestamps()` for `inserted_at` and `updated_at`
- For rolling back, implement `up` and `down` separately instead of relying on `change`
- Always `import Ecto.Query` in `seeds.exs`

## Field Type Rules

- Use `:string` for all text columns, even for long content (no `:text` unless truly massive)
- Use `:utc_now` for timestamp defaults
- Use `:boolean` for flags (with ? suffix in the name) 
- Use `:integer` for counts and foreign keys
- Use `:float` or `:decimal` for monetary values

## Programmatic Fields

Fields set programmatically (e.g. `user_id` from `current_scope.user.id`) must **not** be in `cast`. Set them explicitly in the context.

## Common Patterns

```elixir
def change do
  alter table(:users) do
    add :email, :string
    add :confirmed_at, :utc_now
  end
end
```

## Rolling Back

```bash
mix ecto.rollback
```

## MCP Tools

- `mcp_tidewave_get_ecto_schemas` — list all Ecto schemas to understand existing structure before generating migrations
- `mcp_tidewave_execute_sql_query` — inspect existing table structure

## Anti-patterns

- Do not use `String.to_atom/1` on user input in migrations
- Do not alter system tables or `_runtime` columns
- Do not mix concerns (data transformation + schema change) in one migration
