local ADDON_NAME, ns = ...

ns.utils = {}
local U = ns.utils

-- Safe pcall wrapper that returns ok, result|error
function U.safeCall(fn, ...)
  if type(fn) ~= "function" then return false, "not a function" end
  return pcall(fn, ...)
end

-- Shallow copy (option for deep)
function U.copy(tbl, deep, seen)
  if type(tbl) ~= "table" then return tbl end
  local t = {}
  seen = seen or {}
  seen[tbl] = t
  for k,v in pairs(tbl) do
    if deep and type(v) == "table" then
      if seen[v] then
        t[k] = seen[v]
      else
        t[k] = U.copy(v, true, seen)
      end
    else
      t[k] = v
    end
  end
  return t
end

-- Recursive diff: returns a table of keys whose values differ (new vs old)
function U.diff(newTbl, oldTbl, out, prefix)
  out = out or {}
  prefix = prefix or ""
  if type(newTbl) ~= "table" or type(oldTbl) ~= "table" then
    if newTbl ~= oldTbl then out[prefix or "root"] = newTbl end
    return out
  end
  local checked = {}
  for k,v in pairs(newTbl) do
    local keyPath = prefix ~= "" and (prefix .. "." .. tostring(k)) or tostring(k)
    if type(v) == "table" and type(oldTbl[k]) == "table" then
      U.diff(v, oldTbl[k], out, keyPath)
    elseif v ~= oldTbl[k] then
      out[keyPath] = v
    end
    checked[k] = true
  end
  for k,v in pairs(oldTbl) do
    if not checked[k] then
      local keyPath = prefix ~= "" and (prefix .. "." .. tostring(k)) or tostring(k)
      out[keyPath] = nil -- indicates removal
    end
  end
  return out
end

-- Get unique character key Name-Realm
function U.characterKey(unit)
  unit = unit or "player"
  local name, realm = UnitName(unit)
  realm = realm or GetRealmName()
  return string.format("%s-%s", name or "?", realm or "?")
end

-- Simple throttle helper
function U.throttle(key, interval)
  ns._throttleCache = ns._throttleCache or {}
  local now = GetTime()
  local t = ns._throttleCache[key]
  if not t or now - t >= interval then
    ns._throttleCache[key] = now
    return true
  end
  return false
end
