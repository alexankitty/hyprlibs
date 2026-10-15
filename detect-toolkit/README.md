# detect-toolkit

Detects which GUI toolkit a window uses by scanning its process's loaded libraries.

Includes a script to automatically tag windows with their toolkit.

## Loading it

```lua
local toolkit = require("lib.detect-toolkit")
```

This returns a module table. Nothing is added to the global namespace. Adjust the path to wherever the module lives in your config.

## `toolkit` API

### `toolkit.detect(pid)`

Returns two values for a process ID: the base toolkit and an optional variant. Both are `nil` if no toolkit was detected or `/proc/<pid>/maps` couldn't be read.

Base toolkits are `"qt6"`, `"qt5"`, `"gtk4"`, `"gtk3"` and `"sdl"`. The only variant is `"adwaita"` (libadwaita), which applies to `"gtk4"`.

```lua
local tk, variant = toolkit.detect(hl.get_active_window().pid)
-- "gtk4", "adwaita"
```

### `toolkit.of(window)`

Same as `detect`, but takes a Hyprland window object.

```lua
local tk, variant = toolkit.of(w)

if tk == "gtk4" and variant == "adwaita" then
  -- libadwaita app
end
```

### `toolkit.name(window)`

Returns the base toolkit and variant joined into one string, or `nil` if no toolkit was detected.

```lua
toolkit.name(w)  -- "gtk4-adwaita", "qt6", or nil
```

## Example

```lua
hl.on("window.open", function(w)
  if toolkit.of(w) == nil then
    -- no known toolkit detected
  end
end)
```

## Tagging windows

`detect-toolkit/tags.lua` adds the detected toolkit to each window as a Hyprland tag, so you can match on it in ordinary window rules.

```lua
require("lib.detect-toolkit.tags").enable()
```

Windows get tags like `toolkit_qt6` or `toolkit_gtk4-adwaita`, and `toolkit_none` when nothing was detected.

```lua
hl.window_rule({
  name = "adwaita-rounding",
  match = { tag = "toolkit_gtk4-adwaita" },
  rounding = 12,
})
```

### `tags.enable(opts)`

| Option    | Default      | Description                                                      |
| --------- | ------------ | ---------------------------------------------------------------- |
| `prefix`  | `"toolkit_"` | Prefix for the tag name                                          |
| `none`    | `"none"`     | Suffix used when no toolkit is detected. `false` skips tagging   |
| `toolkit` | auto         | An already-loaded detect-toolkit module, to skip the lookup      |

Requiring `tags` has no effect until `enable()` is called.

## Notes

- Qt is checked before GTK, since Qt apps can load GTK libraries via the platform theme, but GTK apps rarely load Qt.
- The first return value is always the base toolkit, so a check like `toolkit.of(w) == "gtk4"` still matches libadwaita apps.
- `adwaita` means libadwaita, not the Adwaita theme. A GTK4 app that doesn't link libadwaita is reported as plain `gtk4`.
- Detection only sees libraries mapped at scan time, so libraries loaded later with `dlopen` are missed.
- Electron, Chromium, Java and sandboxed (Flatpak) apps often return `nil`.
- Nothing is cached. Each call rescans `/proc/<pid>/maps`, and no cleanup is needed when windows close.
- To pick up edits to the module after a config reload, set `package.loaded["lib.detect-toolkit"] = nil` before requiring it.

## License

GPL-3.0, see the [repository LICENSE](../LICENSE).
