---
name: tidewave
description: Interact with a running Phoenix app via Tidewave MCP for runtime evaluation, SQL queries, and log access. Use in local development only.
---

# Phoenix Runtime Skill

Specialized knowledge for working with a running Phoenix application via
Tidewave MCP. Only for local development.

## Prerequisites

- Phoenix dev server running at `http://127.0.0.1:4000`
- Tidewave MCP connected via `.opencode/opencode.jsonc`

## Capabilities

- Evaluate Elixir expressions in running app context
- Query the database via `Tidewave.sql/1`
- Access application logs via `Tidewave.logs/1`
- Read route helpers and controller specs

## Usage

Start a Phoenix context query:
```
Tidewave.sql("SELECT * FROM users LIMIT 10")
```

Evaluate an expression:
```
Tidewave.eval(User_struct.valid?(%{name: "Alice"}))
```

## Safety

Never run in production. MCP endpoint is unauthenticated by design
(localhost only).
