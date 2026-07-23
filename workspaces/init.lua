--[[
Usage in hyprland.lua:

    local toggle_special = require("toggle_special")

    hl.bind("SUPER + M", function()
      toggle_special.toggle_special("minimized")
    end)

    -- a second, differently-named group works the same way:
    hl.bind("SUPER + SHIFT + M", workspaces.dsp.toggle_special(workspace_name)
    end)

]]

local M = {}
M.dsp = {}

-- Per special-workspace-name memory of the last real workspace a window
-- was pulled from, so toggling back doesn't just dump it on whatever
-- workspace happens to be active right now.
local last_real_workspace = {}

--- Toggle the focused window in/out of the special workspace `special_workspace`.
-- @param special_workspace string|nil defaults to "minimized"
function M.toggle_special(special_workspace)
    special_workspace = special_workspace or "minimized"
    local target_name = "special:" .. special_workspace

    local win = hl.get_active_window()
    if not win or not win.workspace then
        return
    end

    if win.workspace.name == target_name then
        -- Already parked in the special workspace: send it back.
        local real_ws = last_real_workspace[special_workspace] or hl.get_active_workspace()

        hl.dispatch(hl.dsp.window.move({ workspace = real_ws, window = win, follow = false }))
        hl.dispatch(hl.dsp.workspace.toggle_special(special_workspace))
        hl.dispatch(hl.dsp.focus({ window = win }))
    else
        -- On a normal workspace: remember it, then tuck the window away.
        last_real_workspace[special_workspace] = hl.get_active_workspace()
        hl.dispatch(hl.dsp.window.move({ workspace = target_name, window = win, follow = false }))
    end
end

function M.dsp.toggle_special(special_workspace)
    return function()
        M.toggle_special(special_workspace)
    end
end

Workspaces = M
