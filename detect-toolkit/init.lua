local M = {}

-- Order matters: Qt apps can load libgtk via the GTK platform theme,
-- but GTK apps almost never load Qt, so check Qt first.
local signatures = {
    { name = "qt6",  patterns = { "libQt6Core" } },
    { name = "qt5",  patterns = { "libQt5Core" } },
    { name = "gtk4", patterns = { "libgtk-4" } },
    { name = "gtk3", patterns = { "libgtk-3" } },
    { name = "sdl",  patterns = { "libSDL2", "libSDL3" } },
}

local variants = {
    { name = "adwaita", base = "gtk4", patterns = { "libadwaita-1" } },
}

local function has_any(data, patterns)
    for _, p in ipairs(patterns) do
        if data:find(p, 1, true) then return true end -- plain find, no pattern engine
    end
    return false
end

function M.detect(pid)
    if not pid or pid <= 0 then return nil, nil end

    local f = io.open("/proc/" .. pid .. "/maps", "rb")
    if not f then return nil, nil end
    local data = f:read("a")
    f:close()
    if not data then return nil, nil end

    for _, sig in ipairs(signatures) do
        if has_any(data, sig.patterns) then
            for _, var in ipairs(variants) do
                if var.base == sig.name and has_any(data, var.patterns) then
                    return sig.name, var.name
                end
            end
            return sig.name, nil
        end
    end
    return nil, nil
end

--- Same as detect, but takes a window object
function M.of(window)
    if not window then return nil, nil end
    return M.detect(window.pid)
end

--- Combined name, e.g. "gtk4-adwaita", "qt6", or nil
function M.name(window)
    local tk, variant = M.of(window)
    if not tk then return nil end
    return variant and (tk .. "-" .. variant) or tk
end

return M
