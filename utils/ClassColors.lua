local ADDON_NAME, ns = ...

-- WoW API forward declarations
-- luacheck: globals UnitClass

local ClassColors = {}

-- WoW class color definitions
ClassColors.COLORS = {
  WARRIOR = {0.78, 0.61, 0.43},      -- Tan
  PALADIN = {0.96, 0.55, 0.73},      -- Pink
  HUNTER = {0.67, 0.83, 0.45},       -- Green
  ROGUE = {1.0, 0.96, 0.41},         -- Yellow
  PRIEST = {1.0, 1.0, 1.0},          -- White
  SHAMAN = {0.0, 0.44, 0.87},        -- Blue
  MAGE = {0.41, 0.8, 0.94},          -- Light Blue
  WARLOCK = {0.58, 0.51, 0.79},      -- Purple
  MONK = {0.0, 1.0, 0.59},           -- Green
  DRUID = {1.0, 0.49, 0.04},         -- Orange
  DEMONHUNTER = {0.64, 0.19, 0.79}, -- Purple
  DEATHKNIGHT = {0.77, 0.12, 0.23}, -- Red
  EVOKER = {0.2, 0.58, 0.5}          -- Teal
}

-- Get class name from layout data or key
function ClassColors:GetClassName(layout, key)
  -- Use stored class info first
  if layout and layout.playerClass then
    return layout.playerClass
  end
  
  -- Try to extract from key (assumes format like "CharacterName-ClassName")
  if key and key:match("%-(%w+)$") then
    return key:match("%-(%w+)$"):upper()
  end
  
  -- Fallback: use current character's class
  local _, playerClass = UnitClass("player")
  return playerClass
end

-- Get color for a class name
function ClassColors:GetClassColor(className)
  return self.COLORS[className] or {0.8, 0.8, 0.8} -- Default gray
end

-- Format text with class color
function ClassColors:FormatClassText(text, className)
  local color = self:GetClassColor(className)
  return string.format("|cff%02x%02x%02x%s|r", 
    color[1] * 255, color[2] * 255, color[3] * 255, text)
end

-- Get class and spec display text
function ClassColors:GetClassSpecText(layout)
  local classSpecPart = ""
  if layout.playerClass and layout.specName then
    classSpecPart = " ("..layout.playerClass.." - "..layout.specName..")"
  elseif layout.playerClass then
    classSpecPart = " ("..layout.playerClass..")"
  end
  return classSpecPart
end

-- Expose to namespace
ns.classColors = ClassColors