Monitor = {}

function Monitor.Get_Origin()
    local mon = hl.get_monitor_at(0, 0)
    return mon and mon.name or nil
end

function Monitor.Assign_Workspaces(count)
    local monitors = hl.get_monitors()
    local ordered = {}
    local matched = {}
    local monitor_priority = { Monitor.Get_Origin() }

    for _, name in ipairs(monitor_priority) do
        for _, monitor in ipairs(monitors) do
            if monitor.name == name and not matched[monitor.name] then
                table.insert(ordered, monitor)
                matched[monitor.name] = true
            end
        end
    end
    for _, monitor in ipairs(monitors) do
        if not matched[monitor.name] then
            table.insert(ordered, monitor)
        end
    end

    for index, monitor in ipairs(ordered) do
        local base = (index - 1) * count
        for i = 1, count do
            local ws = base + i
            hl.workspace_rule({
                workspace = tostring(ws),
                monitor = monitor.name,
                default = (i == 1),
            })
            -- force any already-existing workspace to actually move too
            hl.dispatch(hl.dsp.workspace.move({ workspace = ws, monitor = monitor.name }))
        end
    end
end

function Monitor.Write_Primary()
    local config_path = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
    local primary = Monitor.Get_Origin()
    local primary_path = config_path .. "/hypr/hyprlock/primary.conf"
    local f = io.open(primary_path, "w")
    if f then
        if primary then
            f:write("$monitor = " .. primary)
        else
            f:write("$monitor = ")
        end
        f:close()
    end
end
