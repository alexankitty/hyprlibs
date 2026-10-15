-- ~/.config/hypr/toolkit.lua
local M = {}

local cache = {}  -- pid -> toolkit name, or false if scanned with no match

-- Order matters: Qt apps can load libgtk via the GTK platform theme,
-- but GTK apps almost never load Qt, so check Qt first.
local signatures = {
    { name = "qt6",  pattern = "libQt6Core" },
    { name = "qt5",  pattern = "libQt5Core" },
    { name = "gtk4", pattern = "libgtk%-4"  },
    { name = "gtk3", pattern = "libgtk%-3"  },
    { name = "sdl",  pattern = "libSDL[23]" },
}

--- Returns "qt6" | "qt5" | "gtk4" | "gtk3" | "sdl" | nil
function M.detect(pid)
if not pid or pid <= 0 then return nil end

    local cached = cache[pid]
    if cached ~= nil then return cached or nil end

        local f = io.open("/proc/" .. pid .. "/maps", "r")
        if not f then return nil end  -- not cached, may succeed later

            local found = {}
            for line in f:lines() do
                for _, sig in ipairs(signatures) do
                    if not found[sig.name] and line:find(sig.pattern) then
                        found[sig.name] = true
                        end
                        end
                        end
                        f:close()

                        for _, sig in ipairs(signatures) do
                            if found[sig.name] then
                                cache[pid] = sig.name
                                return sig.name
                                end
                                end

                                cache[pid] = false
                                return nil
                                end

                                --- Convenience: detect directly from a window object
                                function M.of(window)
                                return window and M.detect(window.pid) or nil
                                end

                                --- Forget a pid (call on window.destroy to avoid stale entries after PID reuse)
                                function M.forget(pid)
                                cache[pid] = nil
                                end

                                return M
