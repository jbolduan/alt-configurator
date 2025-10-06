local ADDON_NAME, ns = ...

local Serialization = {}

-- Serialize a Lua table to string format
function Serialization:SerializeTable(t, indent)
  indent = indent or 0
  local spaces = string.rep("  ", indent)
  local result = "{\n"
  
  for k, v in pairs(t) do
    local keyStr = type(k) == "string" and string.format('["%s"]', k) or string.format("[%s]", tostring(k))
    
    if type(v) == "table" then
      result = result .. spaces .. "  " .. keyStr .. " = " .. self:SerializeTable(v, indent + 1) .. ",\n"
    elseif type(v) == "string" then
      result = result .. spaces .. "  " .. keyStr .. " = \"" .. v .. "\",\n"
    else
      result = result .. spaces .. "  " .. keyStr .. " = " .. tostring(v) .. ",\n"
    end
  end
  
  result = result .. spaces .. "}"
  return result
end

-- Create a formatted layout export string
function Serialization:ExportLayout(layoutKey, layoutData)
  return string.format("-- AltConfig Layout Data for: %s\nlocal layoutData = %s", 
    layoutKey, self:SerializeTable(layoutData))
end

-- Expose to namespace
ns.serialization = Serialization