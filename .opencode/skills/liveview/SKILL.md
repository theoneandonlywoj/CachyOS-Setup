---
name: liveview
description: Build interactive real-time features with Phoenix LiveView. Use when creating LiveViews, working with streams, forms, or JS hooks.
---

# liveview — Phoenix LiveView Development

Use this skill when building interactive, real-time features with Phoenix LiveView.

## When to Use

- Creating a new LiveView (e.g. `mix phx.gen.live`)
- Working with forms in LiveViews
- Implementing real-time updates with streams
- Debugging LiveView state issues

## Naming

- LiveView modules: CamelCase with `Live` suffix (e.g. `UserLive`, `DashboardLive`)
- Router scope already aliases the module, no extra alias needed
- Route names: snake_case (e.g. `:index`, `:edit`)

## Streams — Collections

**Always use streams for collections, not regular list assigns.**

```elixir
# Mount
stream(socket, :items, items)

# Insert
stream(socket, :items, [new_item])

# Delete
stream_delete(socket, :items, item)

# Reset (refetch + re-stream)
stream(socket, :items, items, reset: true)

# Prepend
stream(socket, :items, [new_item], at: -1)
```

Template:
```heex
<div id="items" phx-update="stream">
  <div class="hidden only:block">No items yet</div>
  <div :for={{id, item} <- @streams.items} id={id}>
    {item.name}
  </div>
</div>
```

Streams are **not enumerable**. To filter, refetch and re-stream with `reset: true`.

## Form Handling

```elixir
# From params
assign(socket, form: to_form(params))

# From changesets
assign(socket, form: to_form(changeset))
```

Template:
```heex
<.form for={@form} id="my-form" phx-change="validate" phx-submit="save">
  <.input field={@form[:name]} type="text" />
</.form>
```

- Always use `to_form/2` assigned form, never pass changeset to templates
- Never use `<.form let={f} ...>` — use `<.form for={@form} ...>`

## JavaScript Interop

### Colocated Hooks (preferred)

```heex
<input type="text" id="phone" phx-hook=".PhoneNumber" />
```

```javascript
<script :type={Phoenix.LiveView.ColocatedHook} name=".PhoneNumber">
  export default {
    mounted() {
      this.el.addEventListener("input", e => {
        // format phone
      })
    }
  }
</script>
```

- Hook names must start with `.`
- When using `phx-hook` on JS-managed DOM, also set `phx-update="ignore"`

### External Hooks

```javascript
const MyHook = { mounted() { ... } }
let liveSocket = new LiveSocket("/live", Socket, { hooks: { MyHook } });
```

### Client-Server Events

```elixir
{:noreply, push_event(socket, "my_event", %{data: value})}
```

Client receives: `this.handleEvent("my_event", data => ...)`
Client sends: `this.pushEvent("my_event", payload, reply => ...)`
Server replies: `{:reply, %{result: value}, socket}`

Always rebind socket on `push_event/3`.

## Template Rules

- Wrap all content in `<Layouts.app flash={@flash} ...>`
- Use `<.flash_group>` only in `layouts.ex`
- Use `<.icon name="hero-x-mark" class="w-5 h-5"/>` for icons, never `Heroicons` modules
- No `if/elsif` — use `cond`
- Class lists must use `[...]` syntax
- Never use `<% Enum.each %>` — use `<%= for item <- @collection do %>`

## Layout Errors

`current_scope` errors → check router `live_session` placement and pass `current_scope` to `<Layouts.app>`.

## MCP Tools

- `mcp_tidewave_project_eval` — evaluate LiveView functions in running app
- `mcp_tidewave_get_logs` — check LiveView logs for errors
- `mcp_tidewave_get_source_location` — find LiveView module definitions

## Anti-patterns

- Do not use streams for single-item forms
- Do not use deprecated `phx-update="append"` or `phx-update="prepend"`
- Do not use `live_redirect`/`live_patch` — use `<.link navigate={href}>` / `<.link patch={href}>`
- Do not avoid LiveComponents unless strongly needed
