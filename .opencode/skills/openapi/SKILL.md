---
name: openapi
description: Generate OpenAPI 3.0 specification from Phoenix router. Use when you need to document API endpoints or generate an API contract.
---

# openapi — Generate OpenAPI 3.0 Spec from Phoenix Router

Use this skill when you need to create an OpenAPI 3.0 specification for your Phoenix API.

## When to Use

- Documenting API endpoints for consumers
- Generating API contracts
- Creating OpenAPI specs for API clients
- Setting up API validation with OpenApiSpex

## Prerequisites

Ensure you have `open_api_spex` installed in your Phoenix project:

```elixir
def deps do
  [
    {:open_api_spex, "~> 3.16"}
  ]
end
```

## Step 1: Inspect Router

First, identify your router file and inspect the routes:

```bash
mix phx.routes
```

Or use IEx to get route details:

```elixir
alias Phoenix.Router.Route
routes = Phoenix.Router.routes(MyAppWeb.Router)
Enum.map(routes, fn r -> 
  %{path: r.path, verb: r.verb, plug: r.plug, plug_opts: r.plug_opts}
end)
```

## Step 2: Generate OpenAPI Spec

Create a new file `priv/static/api.json` or generate it dynamically. Here's a template:

```json
{
  "openapi": "3.0.0",
  "info": {
    "title": "Your API Title",
    "version": "1.0.0",
    "description": "API description"
  },
  "servers": [
    {"url": "http://localhost:4000", "description": "Development"}
  ],
  "paths": {
    "/api/resource": {
      "get": {
        "summary": "List resources",
        "tags": ["Resources"],
        "responses": {
          "200": {
            "description": "Successful response",
            "content": {
              "application/json": {
                "schema": {
                  "type": "array",
                  "items": {"$ref": "#/components/schemas/Resource"}
                }
              }
            }
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "Resource": {
        "type": "object",
        "properties": {
          "id": {"type": "integer"},
          "name": {"type": "string"}
        }
      }
    }
  }
}
```

## Step 3: Route Path Conventions

Convert Phoenix routes to OpenAPI paths:

| Phoenix | OpenAPI |
|---------|---------|
| `/api/users/:id` | `/api/users/{id}` |
| `/users/:user_id/posts/:post_id` | `/users/{user_id}/posts/{post_id}` |
| `/api/*path` | `/api/{path}` |

## Step 4: HTTP Method Mapping

| Phoenix Verb | OpenAPI Method |
|--------------|---------------|
| `:get` | `get` |
| `:post` | `post` |
| `:put` | `put` |
| `:patch` | `patch` |
| `:delete` | `delete` |

## Step 5: Request/Response Patterns

### Query Parameters

For `?page=1&per_page=20`:

```json
"parameters": [
  {"name": "page", "in": "query", "schema": {"type": "integer", "default": 1}},
  {"name": "per_page", "in": "query", "schema": {"type": "integer", "default": 20}}
]
```

### Request Body

For JSON request bodies:

```json
"requestBody": {
  "required": true,
  "content": {
    "application/json": {
      "schema": {"$ref": "#/components/schemas/CreateResource"}
    }
  }
}
```

### Error Responses

Always document error cases:

```json
"responses": {
  "400": {"description": "Bad Request"},
  "401": {"description": "Unauthorized"},
  "404": {"description": "Not Found"},
  "422": {"description": "Validation Error"}
}
```

## MCP Tools

- `mcp_tidewave_project_eval` — evaluate route introspection in running app
- `mcp_tidewave_get_source_location` — find controller implementations for documentation

## Anti-patterns

- Do not hardcode production URLs — use environment variables or server configs
- Do not skip error response documentation
- Do not use `type: string` for dates — use `type: string, format: date-time`
- Do not document every HTTP status code — focus on meaningful ones