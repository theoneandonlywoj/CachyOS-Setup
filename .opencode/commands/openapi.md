# openapi — Generate OpenAPI specification

Use the `openapi` skill to generate an OpenAPI 3.0 specification from your Phoenix router.

## Usage

```
/openapi
```

## What it does

1. Inspects your Phoenix router to identify all routes
2. Generates an OpenAPI 3.0 JSON spec template
3. Documents paths, HTTP methods, parameters, and response schemas
4. Saves to `priv/static/api.json` or outputs as markdown

## Prerequisites

- `open_api_spex` in your `mix.exs` dependencies
- Phoenix router with API routes defined

## Next steps

After generation, review and enhance:
- Add request/response body schemas
- Document error cases
- Add authentication requirements
- Update server URLs for different environments

Use the `openapi` skill for detailed guidance on schema definitions.