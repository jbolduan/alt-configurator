local ADDON_NAME, ns = ...
local addon = ns.addon or {}

ns.diagnostics = {}
local D = ns.diagnostics

local REQUIRED_LIBS = {
  "AceAddon-3.0",
  "AceEvent-3.0",
  "AceConsole-3.0",
  "AceDB-3.0",
  "AceGUI-3.0",
  "AceConfigRegistry-3.0",
  "AceConfigDialog-3.0",
  "AceConfig-3.0",
}

local OPTIONAL_LIBS = {
  "AceTimer-3.0",
}

local function check(libName)
  local ok = pcall(function() return LibStub(libName) end)
  return ok
end

function D.Run()
  local results = { missing = {}, present = {}, optionalMissing = {} }
  for _, name in ipairs(REQUIRED_LIBS) do
    if check(name) then table.insert(results.present, name) else table.insert(results.missing, name) end
  end
  for _, name in ipairs(OPTIONAL_LIBS) do
    if check(name) then table.insert(results.present, name) else table.insert(results.optionalMissing, name) end
  end
  ns.diagnostics.last = results
  return results
end

local function announce(results, manual)
  local prefix = "["..ADDON_NAME.." Diag] "
  local dbg = ns.debug
  local function chat(msg)
    DEFAULT_CHAT_FRAME:AddMessage(prefix..msg, 0.4, 0.8, 1)
  end

  if #results.missing == 0 then
    chat("All required libs present.")
    if dbg and dbg.info then dbg:info("Diagnostics: all required libs present.") end
  else
    chat("Missing required libs: "..table.concat(results.missing, ", "))
    if dbg and dbg.error then dbg:error("Missing required libs: %s", table.concat(results.missing, ", ")) end
  end

  if #results.optionalMissing > 0 then
    chat("Optional libs missing: "..table.concat(results.optionalMissing, ", "))
    if dbg and dbg.warn then dbg:warn("Optional libs missing: %s", table.concat(results.optionalMissing, ", ")) end
  end

  if manual then
    local presentCount = #results.present
    chat(string.format("Summary: %d present, %d required missing, %d optional missing.", presentCount, #results.missing, #results.optionalMissing))
  end
end

function D.Report()
  local r = D.Run()
  announce(r, true)
end

-- Auto run at PLAYER_LOGIN to surface issues early
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  local r = D.Run()
  if #r.missing > 0 then
    ns.librariesIncomplete = true
  end
  announce(r, false)
end)
