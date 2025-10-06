local ADDON_NAME, ns = ...

-- Namespace table setup
ns.addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
local addon = ns.addon

-- SavedVariables reference (declare in TOC): altConfiguratorDB
ns.db = nil

-- Module registry helper
ns.modules = {}

function addon:OnInitialize()
  -- Initialize saved variables with defaults
  if not altConfiguratorDB then
    altConfiguratorDB = {
      profile = {
        debug = {
          enabled = true,
          level = 5, -- default to max verbosity so everything shows
          captureStack = false,
        },
        actionBars = {
          layouts = {}, -- key = character or custom name, value = { capturedAt=timestamp, slots = { [1]={type=, id=, subType=, extra=} ... } }
        }
      }
    }
  end
  ns.db = altConfiguratorDB

  self:RegisterChatCommand("altconfig", function(input) ns.commands.HandleSlash(input) end)

  -- Migration: remove deprecated classSync data if present
  if ns.db.profile.classSync then
    ns.db.profile.classSync = nil
    if ns.debug and ns.debug.info then
      ns.debug:info("Removed deprecated classSync data from profile")
    end
  end

  -- Migration: remove deprecated enabled flag
  if ns.db.profile.enabled ~= nil then
    ns.db.profile.enabled = nil
    if ns.debug and ns.debug.info then
      ns.debug:info("Removed deprecated profile.enabled flag")
    end
  end

  -- Ensure actionBars table exists if upgrading from earlier version
  if not ns.db.profile.actionBars then
    ns.db.profile.actionBars = { layouts = {} }
    if ns.debug and ns.debug.info then
      ns.debug:info("Initialized actionBars storage")
    end
  end

  -- Register any modules that loaded before addon existed
  if ns._pendingModuleRegs then
    for _, module in ipairs(ns._pendingModuleRegs) do
      addon:RegisterModule(module.name, module)
    end
    ns._pendingModuleRegs = nil
  end
end

function addon:OnEnable()
  if ns.librariesIncomplete then
    if ns.debug and ns.debug.warn then
      ns.debug:warn("Libraries incomplete - modules not enabled.")
    else
      self:Print("Libraries incomplete - modules not enabled.")
    end
    return
  end
  for name, module in pairs(ns.modules) do
    if module.OnEnable and (not module.IsEnabled or module:IsEnabled()) then
      pcall(module.OnEnable, module)
    end
  end
end

function addon:RegisterModule(name, module)
  ns.modules[name] = module
end
