-- Execution Tools Library
-- Created by Alexankitty
-- Features functions for executing commands and managing running binaries.
-- Supports uwsm launch via your preferred runner set below. runapp is recommend as its faster.
-- ex. "runapp", "uwsm app --"

local uwsm_runner = "runapp"

local info = debug.getinfo(1, 'S')
local this_dir = string.match(info.source, '^@(.*)/')

package.path = this_dir .. "/?.lua;" .. package.path

local Appmgr = __require("appmgr")
App = Appmgr:new(nil, uwsm_runner)
App.Dsp = {}
for k, v in pairs(App) do
    if type(v) == "function" then
        App.Dsp[k] = function(...)
            local args, n = {...}, select("#", ...)
            return function()
                return v(table.unpack(args, 1, n))
            end
        end
    end
end
