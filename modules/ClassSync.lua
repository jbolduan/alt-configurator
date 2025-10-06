local ADDON_NAME, ns = ...
-- addon might not yet exist at file load time if libs failed earlier
local addon = ns.addon

local Module = {}
Module.name = "ClassSync"

function Module:IsEnabled()
  return ns.db and ns.db.profile and ns.db.profile.classSync.enabled
end

-- Placeholder: load or port logic from Class-Synchronizer addon here.
-- Suggested responsibilities:
--  * Gather reference (main) character spec/talents/equipment/action bars
--  * Store template in saved variables
--  * Provide function to apply template to an alt
--  * Hook talent change events to update template if on reference character
--  * Offer AceConfig UI to choose reference character and what to sync

function Module:OnEnable()
  if not self:IsEnabled() then return end
  ns.debug:info("ClassSync module enabled (stub)")

  -- Register for relevant events as needed (example stubs):
  addon:RegisterEvent("PLAYER_LOGIN", function() self:OnPlayerLogin() end)
end

function Module:OnPlayerLogin()
  ns.debug:trace("Player login - ClassSync init stub")
end

-- Public API Example
function Module:ApplyTemplate(targetCharacter)
  -- Implementation would push stored template to the current character
  ns.debug:verbose("ApplyTemplate called for %s (stub)", targetCharacter or ns.utils.characterKey())
end

if ns.addon then
  ns.addon:RegisterModule(Module.name, Module)
else
  ns._pendingModuleRegs = ns._pendingModuleRegs or {}
  table.insert(ns._pendingModuleRegs, Module)
end
