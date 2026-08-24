# monitor

Multi-monitor helpers for Hyprland's Lua config: figuring out which output
sits at the origin, auto-assigning blocks of workspaces per monitor, and
exporting the "primary" monitor's name for other configs (e.g. hyprlock) to
consume.

## Loading it

```lua
require("monitor")
```

This creates a global `Monitor` table.

## `Monitor` API

### `Monitor.Get_Origin()`

Returns the name of the monitor whose top-left corner sits at logical
position `(0, 0)`, or `nil` if none is found there. This is treated as the
"primary" monitor throughout the rest of the library.

```lua
local primary = Monitor.Get_Origin()
-- e.g. "DP-1"
```

### `Monitor.Assign_Workspaces(count)`

Assigns `count` sequential workspaces to each connected monitor, ordered so
the origin monitor gets workspaces `1..count`, and every other monitor gets
the next block after it (`count+1..2*count`, and so on). The first workspace
in each monitor's block is set as that monitor's default, and any existing
workspaces are actively moved to their new monitor.

```lua
-- Give every monitor 5 workspaces of its own, origin monitor first
Monitor.Assign_Workspaces(5)
```

Useful in a `hyprland.start` handler so workspace layout re-computes
whenever your monitor setup changes:

```lua
hl.on("hyprland.start", function()
    Monitor.Assign_Workspaces(5)
end)
```

### `Monitor.Write_Primary()`

Writes the origin monitor's name to
`$XDG_CONFIG_HOME/hypr/hyprlock/primary.conf` (falling back to
`~/.config` if `XDG_CONFIG_HOME` isn't set) as:

```
$monitor = DP-1
```

If no origin monitor is found, it writes an empty `$monitor =` instead. This
is meant to be `source`d from your `hyprlock.conf` so lock-screen widgets can
target the primary display without hardcoding its name:

```
# hyprlock.conf
source = ~/.config/hypr/hyprlock/primary.conf
```

```lua
-- Keep primary.conf in sync at startup
hl.on("hyprland.start", function()
    Monitor.Write_Primary()
end)
```

### `Monitor.Process_Disabled()`
Runs through a list of Monitors provided in the `Monitor.Disabled` table and sets them to disabled so that they do not show up.

Add in an event listener to process the disabled output list whenever a monitor is added or removed.

```lua
local function handle_monitor_event()
    Monitor.Process_Disabled()
    Monitor.Assign_Workspaces(workspaces_per_monitor)
    Monitor.Write_Primary()
end

handle_monitor_event()
hl.on("monitor.added", handle_monitor_event)
hl.on("monitor.removed", handle_monitor_event)
```

## License

GPL-3.0, see the [repository LICENSE](../LICENSE).
