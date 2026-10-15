local M = {}

-- Order matters: Qt apps can load libgtk via the GTK platform theme,
-- but GTK apps almost never load Qt, so check Qt first.
local signatures = {
    { name = "qt6",  pattern = "libQt6Core" },
    { name = "qt5",  pattern = "libQt5Core" },
    { name = "gtk4", pattern = "libgtk%-4"  },
    { name = "gtk3", pattern = "libgtk%-3"  },
    { name = "sdl",  pattern = "libSDL[23]" },
}

-- Variants layered on top of a base toolkit
local variants = {
    { name = "adwaita", base = "gtk4", pattern = "libadwaita%-1" },
}

--- Returns toolkit, variant   e.g. "gtk4", "adwaita"  |  "qt6", nil  |  nil, nil
function M.detect(pid)
    if not pid or pid <= 0 then return nil, nil end

    local f = io.open("/proc/" .. pid .. "/maps", "r")
    if not f then return nil, nil end

    local found = {}
    for line in f:lines() do
        for _, sig in ipairs(signatures) do
            if not found[sig.name] and line:find(sig.pattern) then
                found[sig.name] = true
            end
        end
        for _, var in ipairs(variants) do
            if not found[var.name] and line:find(var.pattern) then
                found[var.name] = true
            end
        end
    end
    f:close()

    for _, sig in ipairs(signatures) do
        if found[sig.name] then
            for _, var in ipairs(variants) do
                if var.base == sig.name and found[var.name] then
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
