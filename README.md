# hyprlibs

Small Lua libraries for [Hyprland](https://hypr.land)'s native Lua
configuration system (introduced in Hyprland 0.55), covering common config
needs that aren't built in: process/app management and multi-monitor
workspace setup.

Each library is self-contained and lives in its own folder — pull in only
the ones you need.

## Requirements

- Hyprland **0.55+** (Lua config support)
- `hyprctl`/the Lua config engine's `hl` global available at config load time

## Libraries

| Library | Description |
|---|---|
| [`app-mgmt`](app-mgmt/README.md) | Run, kill, delay, and dedupe application launches, with optional [uwsm](https://github.com/Vladimir-csp/uwsm) support and deferred/dispatcher-friendly variants for keybinds. |
| [`monitor`](monitor/README.md) | Detect the origin/primary monitor, auto-assign per-monitor workspace blocks, and export the primary monitor's name for use in other configs (e.g. hyprlock). |

See each library's own README for its full API and usage examples.

## Installation

Clone the repo somewhere under your Hyprland config, e.g.:

```sh
git clone https://github.com/alexankitty/hyprlibs ~/.config/hypr/lua/hyprlibs
```

Then `require` whichever libraries you want from `hyprland.lua`:

```lua
-- hyprland.lua
package.path = os.getenv("HOME") .. "/.config/hypr/lua/hyprlibs/?/init.lua;" .. package.path

require("app-mgmt")
require("monitor")

App.Exec_Once("waybar")

hl.on("hyprland.start", function()
    Monitor.Assign_Workspaces(5)
    Monitor.Write_Primary()
end)
```

> [!NOTE]
> Lua scripts in your Hyprland config can execute arbitrary code — only use
> libraries (including this one) from sources you trust.

## License

Licensed under the [GNU General Public License v3.0](LICENSE).
