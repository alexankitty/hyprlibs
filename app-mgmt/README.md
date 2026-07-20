# app-mgmt

Execution and process-management helpers for Hyprland's Lua config. Wraps the
common "run this, but kill it first / only if it's not already running / with
a delay" patterns into a small `App` API, with optional [uwsm](https://github.com/Vladimir-csp/uwsm)
support baked in.

## Loading it

Requiring `app-mgmt/init.lua` sets up the module's own `package.path` entry
and creates a global `App` table:

```lua
require("app-mgmt")
```

By default, commands run through `App.Runapp*` are launched via the `runapp`
uwsm helper. If you'd rather use `uwsm app --` (or nothing at all), edit the
`uwsm_runner` local at the top of `init.lua`:

```lua
local uwsm_runner = "runapp"        -- default, fastest option
-- local uwsm_runner = "uwsm app --"
```

## `App` API

All functions take a shell command string. Where a separate `true_name` is
accepted, it's used to identify the *running* process (via `pidof`) when it
differs from the command you're launching it with — e.g. launching
`'my-app' --flag` but checking for the process `my-app`.

| Function | Behavior |
|---|---|
| `App.Exec(cmd)` | Runs `cmd` directly via `hl.exec_cmd`. |
| `App.Kill(cmd)` | Kills the binary parsed out of `cmd` (via `killall`). |
| `App.Runapp(cmd)` | Runs `cmd` through the configured uwsm runner. |
| `App.Exec_Delayed(cmd, delay)` | Sleeps `delay` seconds, then runs `cmd`. |
| `App.Runapp_Delayed(cmd, delay)` | Sleeps `delay` seconds, then runs `cmd` through the uwsm runner. |
| `App.Exec_Replace(cmd, true_name?)` | Kills any running instance first, then runs `cmd`. |
| `App.Runapp_Replace(cmd, true_name?)` | Kills any running instance first, then runs `cmd` through the uwsm runner. |
| `App.Exec_Once(cmd, true_name?)` | Runs `cmd` only if it isn't already running. |
| `App.Runapp_Once(cmd, true_name?)` | Runs `cmd` through the uwsm runner only if it isn't already running. |

Process detection is done with `pidof` against the binary name — either the
quoted portion at the start of `cmd` (`'my-app' --flag`) or the first
whitespace-delimited token.

### Examples

```lua
require("app-mgmt")

-- Just run something
App.Exec("waybar")

-- Don't relaunch waybar if it's already up
App.Exec_Once("waybar")

-- Restart a launcher-style binary via uwsm, killing any prior instance
App.Runapp_Replace("'rofi' -show drun", "rofi")

-- Give a compositor-dependent app a moment before starting it
App.Runapp_Delayed("nm-applet", 2)
```

### `App.Dsp` — deferred/dispatcher versions

Every `App` function also has a matching entry under `App.Dsp` that, instead
of running immediately, returns a zero-argument closure over the same
arguments. This is handy anywhere Hyprland's Lua API wants a callback rather
than an immediate call, such as keybinds:

```lua
require("app-mgmt")

hl.bind({
    mods = "SUPER",
    key = "return",
    dispatcher = App.Dsp.Runapp_Once("kitty"),
})
```

Calling `App.Dsp.Runapp_Once("kitty")` doesn't launch anything on its own —
it hands back a function that will, when later invoked by Hyprland, call
`App.Runapp_Once("kitty")`.

## License

GPL-3.0, see the [repository LICENSE](../LICENSE).
