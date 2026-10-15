-- detect-toolkit/tags.lua
--
-- Tags windows with their detected toolkit, e.g. "toolkit_gtk4-adwaita".
-- Requiring this module does nothing until enable() is called.

-- `...` is the name this file was required under, e.g. "lib.detect-toolkit.tags".
-- Stripping the trailing ".tags" gives the parent module, so this keeps working
-- wherever the package is placed.
local modname = ...
local parent = type(modname) == "string" and modname:match("^(.*)%.tags$") or nil

local M = {}

--- Start tagging windows as they open.
--- @param opts table|nil
---   prefix  string  Tag prefix (default "toolkit_")
---   none    string  Tag suffix for windows with no detected toolkit (default "none", false to skip)
---   toolkit table   An already-loaded detect-toolkit module (skips the lookup)
function M.enable(opts)
  opts = opts or {}
  local prefix = opts.prefix or "toolkit_"
  local none = opts.none
  if none == nil then none = "none" end

  local toolkit = opts.toolkit
  if not toolkit then
    if not parent then
      error("detect-toolkit.tags: could not work out the parent module; "
        .. "require it as '<path>.tags' or pass opts.toolkit", 2)
    end
    toolkit = require(parent)
  end

  hl.on("window.open_early", function(w)
    if not w then return end

    local suffix = toolkit.name(w) or none
    if not suffix then return end

    hl.dispatch(hl.dsp.window.tag({
      tag = "+" .. prefix .. suffix,
      window = w,
    }))
  end)
end

return M
