# toolkit

Detects which GUI toolkit a window uses by scanning its process's loaded libraries.
Will automatically tag a window with its toolkit.

## Loading it

```lua
local toolkit = require("toolkit")
```

This returns a module table. Nothing is added to the global namespace.

## `toolkit` API

### `toolkit.detect(pid)`

Returns the toolkit name for a process ID, or `nil` if none was detected or `/proc/<pid>/maps` couldn't be read. Detected names are `"qt6"`, `"qt5"`, `"gtk4"`, `"gtk3"` and `"sdl"`.

```lua
toolkit.detect(hl.get_active_window().pid)
```

### `toolkit.of(window)`

Same as `detect`, but takes a Hyprland window object.

```lua
toolkit.of(w)
```

### `toolkit.forget(pid)`

Clears the cached result for a PID. Call it on `window.destroy` so a reused PID doesn't return a stale result.

```lua
hl.on("window.destroy", function(w)
  if w then toolkit.forget(w.pid) end
end)
```

## Example

```lua
hl.on("window.open", function(w)
  if toolkit.of(w) == nil then
    -- no known toolkit detected
  end
end)
```

## Notes

- Qt is checked before GTK, since Qt apps can load GTK libraries via the platform theme, but GTK apps rarely load Qt.
- Electron, Chromium, Java and sandboxed (Flatpak) apps often return `nil`.
- Results are cached per PID. To pick up edits to the module after a config reload, set `package.loaded["toolkit"] = nil` before requiring it.

## License

GPL-3.0, see the [repository LICENSE](../LICENSE).
