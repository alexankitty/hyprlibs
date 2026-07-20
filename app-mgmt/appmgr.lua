local appmgr = { uwsm_runner = nil }

function appmgr:new(o, uwsm_runner)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.uwsm_runner = uwsm_runner or "runapp"

    -- Helper Functions
    o.Get_Binary = function(cmd)
        return string.match(cmd, "^'(.-)'") or string.match(cmd, "^(%S+)")
    end

    o.Is_Running = function(cmd)
        local binary = o.Get_Binary(cmd)
        local i, t, popen = 0, {}, io.popen
        local pfile = popen("pidof " .. binary)
        for pid in pfile:lines() do
            t[i] = pid
            i = i + 1
        end
        pfile:close()
        return i > 0
    end

    -- Components for building a shell command string reusably.
    o.Cmd_Builder = function(cmd)
        local b = { parts = {}, final = cmd }

        b.Kill = function(self, true_name)
            table.insert(self.parts, "killall " .. o.Get_Binary(true_name or self.final))
            return self
        end

        b.Delay = function(self, delay)
            table.insert(self.parts, "sleep " .. delay)
            return self
        end

        b.Runapp = function(self)
            self.final = o.uwsm_runner .. " " .. self.final
            return self
        end

        b.Build = function(self)
            table.insert(self.parts, self.final)
            return table.concat(self.parts, " && ")
        end

        return b
    end

    -- Execution

    o.Exec = function(cmd)
        hl.exec_cmd(cmd)
    end

    -- This is technically redundant as you should probably just use hl.dsp.close() instead
    o.Kill = function(cmd)
        o.Exec(o.Cmd_Builder(cmd):Kill():Build())
    end

    o.Runapp = function(cmd)
        return o.Exec(o.Cmd_Builder(cmd):Runapp():Build())
    end

    o.Exec_Delayed = function(cmd, delay)
        return o.Exec(o.Cmd_Builder(cmd):Delay(delay):Build())
    end

    o.Runapp_Delayed = function(cmd, delay)
        return o.Exec(o.Cmd_Builder(cmd):Delay(delay):Runapp():Build())
    end

    o.Exec_Replace = function(cmd, true_name)
        true_name = true_name or cmd
        local builder = o.Cmd_Builder(cmd)
        if o.Is_Running(true_name) then
            builder:Kill(true_name)
        end
        return o.Exec(builder:Build())
    end

    o.Runapp_Replace = function(cmd, true_name)
        true_name = true_name or cmd
        local builder = o.Cmd_Builder(cmd):Runapp()
        if o.Is_Running(true_name) then
            builder:Kill(true_name)
        end
        return o.Exec(builder:Build())
    end

    o.Exec_Once = function(cmd, true_name)
        true_name = true_name or cmd
        if not o.Is_Running(true_name) then
            return o.Exec(o.Cmd_Builder(cmd):Build())
        end
    end

    o.Runapp_Once = function(cmd, true_name)
        true_name = true_name or cmd
        if not o.Is_Running(true_name) then
            return o.Exec(o.Cmd_Builder(cmd):Runapp():Build())
        end
    end

    return o
end

return appmgr
