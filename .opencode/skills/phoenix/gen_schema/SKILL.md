# gen_schema — Generate Ecto Schemas

Use this skill when you need to create a new Ecto schema for a data model, or add fields to an existing schema.

## When to Use

- Creating a new data model (e.g. `mix phx.gen.schema User users name:string email:string`)
- Adding a new schema file
- Understanding schema field conventions

## Command

```bash
mix phx.gen.schema SchemaName table_name field_name:type field_name:type
```

## Conventions

- Schema names are CamelCase (e.g. `User`, `OrderItem`)
- Table names are plural snake_case (e.g. `users`, `order_items`)
- Use `field :name, :string` for ALL text fields, even long content
- Use `field :inserted_at, :utc_now` and `field :updated_at, :utc_now` for timestamps
- Programmatic fields (set in code, not from DB) must **not** be in `cast/4`
- Always preload associations when accessed in templates

## Field Types

| Ecto type | Use for |
|---|---|
| `:string` | Short text, names, emails, titles |
| `:text` | Very long content (rare, justified by size only) |
| `:integer` | Counts, IDs, numeric values |
| `:float` | Precise scientific values |
| `:decimal` | Monetary values, financial data |
| `:boolean` | Flags, toggles |
| `:date`, `:time`, `:utc_datetime` | Date/time fields |
| `:uuid` | Unique identifiers |
| `:array` | Arrays of primitives |
| `:map` | Key-value data |

## BelongsTo / Associations

```elixir
belongs_to :user, App.Accounts.User
has_many :comments, App.Content.Comment
many_to_many :tags, App.Content.Tag, join_through: "posts_tags"
```

## Primary Key

Phoenix uses `field :id, :id` by default (auto-increment). For UUID primary keys, configure in `mix.exs`.

## Timestamps

```elixir
timestamps(type: :utc_datetime)
```

## MCP Tools

- `mcp_tidewave_get_ecto_schemas` — list all schemas to check for naming conflicts before generating
- `mcp_tidewave_get_source_location` — find existing schema definitions for reference

## Anti-patterns

- Do not use `string` (lowercase) as type — use `:string` (atom)
- Do not put programmatic fields in `cast`
- Do not use `embeds_one`/`embeds_many` unless the embedded data has no separate table
