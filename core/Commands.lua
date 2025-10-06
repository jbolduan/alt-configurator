local ADDON_NAME, ns = ...
local addon = ns.addon

ns.commands = {}

local function help()
  addon:Print("Alt Configurator commands:")
  addon:Print("/altconfig (no args) - Open GUI")
  addon:Print("/altconfig help - Show this help")
  addon:Print("/altconfig debug - Toggle debug logging")
  addon:Print("/altconfig debuglevel [1-5] - Show or set debug verbosity (omit number to list)")
  addon:Print("/altconfig diag - Run library diagnostics")
end

function ns.commands.HandleSlash(input)
  input = (input or ""):lower():trim()
  if input == "" then
    if ns.gui then
      ns.gui:Toggle()
    else
      addon:Print("GUI unavailable; use /altconfig help for commands.")
    end
  elseif input == "help" then
    help()
  elseif input == "debug" then
    local dbg = ns.db.profile.debug
    dbg.enabled = not dbg.enabled
    addon:Print("Debug logging: " .. tostring(dbg.enabled))
  elseif input:match("^debuglevel") then
    local lvl = tonumber(input:match("^debuglevel%s+(%d)"))
    if not lvl then
      local cur = ns.db.profile.debug.level
      addon:Print("Current debug level: "..cur)
      addon:Print("1=ERROR 2=WARN 3=INFO 4=VERBOSE 5=TRACE")
      addon:Print("Use /altconfig debuglevel <n> to change.")
    else
      if lvl >=1 and lvl <=5 then
        ns.db.profile.debug.level = lvl
        addon:Print("Debug level set to " .. lvl)
      else
        addon:Print("Level must be 1-5")
      end
    end
  elseif input == "diag" then
    if ns.diagnostics and ns.diagnostics.Report then
      ns.diagnostics.Report()
    else
      addon:Print("Diagnostics module not available.")
    end
  else
    addon:Print("Unknown command. Type /altconfig help")
  end
end
