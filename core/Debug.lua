local ADDON_NAME, ns = ...
local addon = ns.addon

ns.debug = {}
local D = ns.debug

D.levels = { ERROR=1, WARN=2, INFO=3, VERBOSE=4, TRACE=5 }

local levelNames = { [1]="ERROR", [2]="WARN", [3]="INFO", [4]="VERBOSE", [5]="TRACE" }

local function shouldLog(level)
  local db = ns.db
  if not db or not db.profile.debug.enabled then return false end
  return level <= (db.profile.debug.level or 1)
end

function D.isEnabled()
  local db = ns.db
  return db and db.profile.debug.enabled
end

local function formatMsg(level, msg)
  return string.format("[%s][%s] %s", ADDON_NAME, levelNames[level] or level, msg)
end

local function maybeStack()
  if ns.db and ns.db.profile.debug.captureStack then
    return "\n"..debugstack(3,3,3)
  end
  return ""
end

function D.log(level, msg, ...)
  if type(level) == "string" then level = D.levels[level] or 3 end
  if not shouldLog(level) then return end
  if select('#', ...) > 0 then
    msg = string.format(tostring(msg), ...)
  end
  addon:Print(formatMsg(level, msg)..maybeStack())
end

function D:error(msg, ...) D.log(D.levels.ERROR, msg, ...) end
function D:warn(msg, ...)  D.log(D.levels.WARN, msg, ...) end
function D:info(msg, ...)  D.log(D.levels.INFO, msg, ...) end
function D:verbose(msg, ...) D.log(D.levels.VERBOSE, msg, ...) end
function D:trace(msg, ...) D.log(D.levels.TRACE, msg, ...) end

-- Profiler utility (simple elapsed timer)
function D.time(label)
  local start = debugprofilestop()
  return function()
    local elapsed = debugprofilestop() - start
    D:trace("%s took %.2f ms", label or "segment", elapsed)
    return elapsed
  end
end
