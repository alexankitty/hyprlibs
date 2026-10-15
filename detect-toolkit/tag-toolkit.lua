local PREFIX = "toolkit_"  -- tags become e.g. toolkit_qt6, toolkit_gtk3, toolkit_none

hl.on("window.open_early", function(w)
  if not w then return end

  local tk = toolkit.name(w) or "none"

  hl.dispatch(hl.dsp.window.tag({
    tag = "+" .. PREFIX .. tk,
    window = w,
  }))
end)
