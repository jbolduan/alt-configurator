local ADDON_NAME, ns = ...
local addon = ns.addon

ns.options = {}

local AceConfig = LibStub("AceConfig-3.0", true)
local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
local AceGUI = LibStub("AceGUI-3.0", true)

if not (AceConfig and AceConfigDialog and AceGUI) then
  -- If libs not present, schedule a warning after login and skip defining options
  local f = CreateFrame("Frame")
  f:RegisterEvent("PLAYER_LOGIN")
  f:SetScript("OnEvent", function()
    if not AceGUI then
      if ns.debug and ns.debug.error then
        ns.debug:error("AceGUI-3.0 missing; configuration UI disabled. Check manifest.xml includes.")
      else
        print("[Alt Configurator] AceGUI-3.0 missing; configuration UI disabled. Check manifest.xml includes.")
      end
    end
  end)
  return
end

local function GetOptions()
  local o = {
    type = "group",
    name = "Alt Configurator",
    args = {
      -- General group removed (only contained deprecated Enabled toggle)
      debug = {
        type = "group",
        name = "Debug",
        inline = true,
        args = {
          dbgEnabled = {
            type = "toggle",
            name = "Enable Debug Logging",
            get = function() return ns.db.profile.debug.enabled end,
            set = function(_, v) ns.db.profile.debug.enabled = v end,
            order = 1
          },
          dbgLevel = {
            type = "range",
            name = "Verbosity Level",
            desc = "1=ERROR 2=WARN 3=INFO 4=VERBOSE 5=TRACE",
            min = 1, max = 5, step = 1,
            get = function() return ns.db.profile.debug.level end,
            set = function(_, v) ns.db.profile.debug.level = v end,
            order = 2,
            disabled = function() return not ns.db.profile.debug.enabled end
          },
          dbgStack = {
            type = "toggle",
            name = "Capture Stack",
            desc = "Append partial stack traces to log lines.",
            get = function() return ns.db.profile.debug.captureStack end,
            set = function(_, v) ns.db.profile.debug.captureStack = v end,
            order = 3,
            disabled = function() return not ns.db.profile.debug.enabled end
          },
        }
      },
    }
  }
  return o
end

function ns.options.Register()
  if not AceConfig or not AceConfigDialog then return end
  if not ns._optionsRegistered then
    AceConfig:RegisterOptionsTable(ADDON_NAME, GetOptions())
    AceConfigDialog:AddToBlizOptions(ADDON_NAME, "Alt Configurator")
    ns._optionsRegistered = true
  end
end

-- Delay registration until ADDON_LOADED to ensure DB exists
addon:RegisterEvent("ADDON_LOADED", function(_, name)
  if name == ADDON_NAME then
    ns.options.Register()
  end
end)
