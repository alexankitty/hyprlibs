# workspaces

Multi-monitor helpers for Hyprland's Lua config: figuring out which output
sits at the origin, auto-assigning blocks of workspaces per monitor, and
exporting the "primary" monitor's name for other configs (e.g. hyprlock) to
consume.

## Loading it

```lua
require("workspaces")
```

This creates a global `Workspaces` table.

## `Workspaces` API

### `Workspaces.toggle_special()`

Moves the window to/from the special/workspace group.

```lua
Workspaces.toggle_special("workspace_name")
```

### `Workspaces.dsp.toggle_special()`

Returns a function that toggles the special/workspace group on the display. Useful for keybindings, and follows the same dsp syntax as Hyprland dispatcher functions.

```lua
Workspaces.dsp.toggle_special("workspace_name")
```

## License

GPL-3.0, see the [repository LICENSE](../LICENSE).
