local ADDON_NAME, ns = ...
local addon = ns.addon

-- Ace3 library refs (loaded by TOC before this file in WoW environment)
local AceGUI = LibStub and LibStub("AceGUI-3.0")

-- GuiManager: central UI for addon & future modules
local Gui = {}
Gui.name = "GuiManager"

-- Internal state
local frame
local tabs
local currentTab
local panels = {} -- key -> { title=, build = function(container) end }
local selectedLayoutKey -- for action bars selection state
local pendingRenameKey
local selectedClassFilter -- for class filtering
local classFilterWidget -- reference to the dropdown widget

-- WoW API forward declarations (helps static analyzers; actual provided at runtime)
-- NOTE: These globals exist in the WoW environment; we don't redefine them here.
-- luacheck: globals GetActionInfo PickupSpell PickupItem PickupMacro PickupAction PlaceAction ClearCursor CursorHasSpell CursorHasItem CursorHasMacro ClearAction InCombatLockdown StaticPopupDialogs StaticPopup_Show YES NO time date C_Spell C_Item C_Timer AceGUI LibStub UnitClass GetSpecialization GetSpecializationInfo

-- Helper function to build class options from stored layouts
local function buildClassOptions()
  local classOptions = {
    ["ALL"] = "All Classes"
  }
  
  -- Add available classes from stored layouts
  local store = ns.db.profile.actionBars.layouts
  for key, layout in pairs(store) do
    local className = nil
    if ns.classColors then
      className = ns.classColors:GetClassName(layout, key)
    end
    if className and not classOptions[className] then
      -- Format class name nicely
      local displayName = className:sub(1,1) .. className:sub(2):lower()
      classOptions[className] = displayName
    end
  end
  
  return classOptions
end

-- Helper function to update class filter dropdown options
local function updateClassFilterOptions()
  if classFilterWidget then
    local currentValue = classFilterWidget:GetValue()
    local newOptions = buildClassOptions()
    classFilterWidget:SetList(newOptions)
    
    -- Preserve current selection if it still exists, otherwise reset to ALL
    if newOptions[currentValue] then
      classFilterWidget:SetValue(currentValue)
    else
      classFilterWidget:SetValue("ALL")
      selectedClassFilter = "ALL"
    end
  end
end

local function buildOverview(container)
  container:ReleaseChildren()
  local label = AceGUI:Create("Label")
  label:SetText("Alt Configurator\n\nOverview panel placeholder. Future summary, stats, and quick actions will go here.")
  label:SetFullWidth(true)
  container:AddChild(label)
end



-- Clean, stable GUI builder for Action Bars
local function buildActionBars(container)
  container:ReleaseChildren()

  -- Try direct addition to container instead of nested groups
  local header = AceGUI:Create("SimpleGroup")
  header:SetFullWidth(true)
  header:SetLayout("Flow")
  container:AddChild(header)

  -- Buttons
  local captureBtn = AceGUI:Create("Button")
  captureBtn:SetText("Capture Current Bars")
  captureBtn:SetWidth(200) -- Wider to show all text
  captureBtn:SetCallback("OnClick", function()
    if ns.actionBarManager then
      local newKey = ns.actionBarManager:CaptureActionBars()
      selectedLayoutKey = newKey
      -- Update class filter options to include any new classes
      updateClassFilterOptions()
      buildActionBars(container)
    end
  end)
  header:AddChild(captureBtn)
  
  -- Class filter dropdown
  local classFilter = AceGUI:Create("Dropdown")
  classFilter:SetWidth(120)
  classFilter:SetLabel("Filter by Class:")
  
  -- Build class options using helper function
  local classOptions = buildClassOptions()
  
  -- Get current player class as default (only if not already set)
  local defaultClass = selectedClassFilter
  if not defaultClass then
    local _, currentClass = UnitClass("player")
    defaultClass = currentClass or "ALL"
    selectedClassFilter = defaultClass
  end
  
  classFilter:SetList(classOptions)
  classFilter:SetValue(defaultClass)
  classFilter:SetCallback("OnValueChanged", function(widget, event, value)
    selectedClassFilter = value
    buildActionBars(container)
  end)
  
  -- Store widget reference for updates
  classFilterWidget = classFilter
  header:AddChild(classFilter)





  -- Simple ScrollFrame directly added to container
  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetFullWidth(true)
  scroll:SetFullHeight(true)
  scroll:SetLayout("List")
  container:AddChild(scroll)

  -- Data population
  local store = ns.db.profile.actionBars.layouts
  local keys = {}; for k in pairs(store) do keys[#keys+1]=k end; table.sort(keys)

  if #keys == 0 then
    local none = AceGUI:Create("Label")
    none:SetText("No saved action bar layouts. Click 'Capture Current Bars' to create one.")
    none:SetFullWidth(true)
    none:SetHeight(26) -- Match row height for consistency
    scroll:AddChild(none)
  else
    local rowIndex = 0 -- For alternating backgrounds after filtering
    for i, key in ipairs(keys) do
      local layout = store[key]
      
      -- Apply class filtering
      local shouldShow = true
      if selectedClassFilter and selectedClassFilter ~= "ALL" then
        local layoutClass = nil
        if ns.classColors then
          layoutClass = ns.classColors:GetClassName(layout, key)
        end
        shouldShow = (layoutClass == selectedClassFilter)
      end
      
      if shouldShow then
        rowIndex = rowIndex + 1
        
        -- Create a row container with Flow layout for each layout
      local row = AceGUI:Create("SimpleGroup")
      row:SetFullWidth(true)
      row:SetLayout("Flow")
      row:SetHeight(26) -- Slightly taller to account for Flow layout spacing
      
      -- Force frame height to ensure consistency
      if row.frame then
        row.frame:SetHeight(26)
      end
      
      -- Add alternating row background (use rowIndex-1 so first row is even/darker)
      if ns.guiUtils then
        ns.guiUtils:CreateRowBackground(row, (rowIndex - 1) % 2 == 0)
      end
      
      scroll:AddChild(row)
      
      -- Layout info (name, class/spec, timestamps) with class coloring
      local infoLabel = AceGUI:Create("Label")
      if ns.guiUtils then
        local displayText = ns.guiUtils:FormatLayoutDisplayText(key, layout)
        infoLabel:SetText(displayText)
      else
        infoLabel:SetText(key .. " - " .. date("%m-%d %H:%M", layout.capturedAt))
      end
      infoLabel:SetWidth(420)
      row:AddChild(infoLabel)
      
      -- Determine if this is an even row (darker) or odd row (lighter)
      local isEvenRow = (rowIndex - 1) % 2 == 0
      
      -- Apply button for this row
      local applyRowBtn = AceGUI:Create("Button")
      applyRowBtn:SetText("Apply")
      applyRowBtn:SetWidth(70)
      applyRowBtn:SetCallback("OnClick", function()
        if InCombatLockdown and InCombatLockdown() then 
          print("AltConfig: Cannot apply layouts while in combat.")
          return 
        end
        if ns.dialogs then
          ns.dialogs:ShowApplyDialog(key)
        end
      end)
      row:AddChild(applyRowBtn)
      
      -- Rename button for this row
      local renameRowBtn = AceGUI:Create("Button")
      renameRowBtn:SetText("Rename")
      renameRowBtn:SetWidth(95)
      renameRowBtn:SetCallback("OnClick", function()
        if ns.dialogs then
          ns.dialogs:ShowRenameDialog(key, function(newName)
            selectedLayoutKey = newName
            buildActionBars(container)
          end)
        end
      end)
      row:AddChild(renameRowBtn)
      
      -- Delete button for this row
      local deleteRowBtn = AceGUI:Create("Button")
      deleteRowBtn:SetText("Delete")
      deleteRowBtn:SetWidth(95)
      deleteRowBtn:SetCallback("OnClick", function()
        if ns.dialogs then
          ns.dialogs:ShowDeleteDialog(key, function()
            buildActionBars(container)
          end)
        end
      end)
      row:AddChild(deleteRowBtn)
      
      -- Copy button for this row
      local copyRowBtn = AceGUI:Create("Button")
      copyRowBtn:SetText("Copy")
      copyRowBtn:SetWidth(65)
      copyRowBtn:SetCallback("OnClick", function()
        if ns.dialogs then
          ns.dialogs:ShowCopyDialog(key, layout)
        end
      end)
      row:AddChild(copyRowBtn)
      
      -- Apply row-matching backgrounds to all buttons
      if ns.guiUtils then
        ns.guiUtils:ApplyRowColorToButton(applyRowBtn, isEvenRow)
        ns.guiUtils:ApplyRowColorToButton(renameRowBtn, isEvenRow)
        ns.guiUtils:ApplyRowColorToButton(deleteRowBtn, isEvenRow)
        ns.guiUtils:ApplyRowColorToButton(copyRowBtn, isEvenRow)
      end
      end -- end shouldShow
    end -- end for loop
    if ns.guiUtils then
      ns.guiUtils:ResetScrollPosition(scroll)
    end
  end
end



-- Register default panels
panels["overview"] = { title = "Overview", build = buildOverview }
panels["actionbars"] = { title = "Action Bars", build = buildActionBars }

function Gui:RegisterPanel(key, title, buildFunc)
  if not key or panels[key] then return false end
  panels[key] = { title = title or key, build = buildFunc }
  if frame and tabs then
    tabs:SetTabs(Gui:_composeTabs())
  end
  return true
end

function Gui:_composeTabs()
  local t = {}
  for key, def in pairs(panels) do
    table.insert(t, { text = def.title, value = key })
  end
  --table.sort(t, function(a,b) return a.text < b.text end)
  return t
end

local function SelectTab(widget, event, value)
  currentTab = value
  local panel = panels[value]
  if panel and panel.build then
    panel.build(widget) -- pass container (the tab group itself is the container)
  end
end

function Gui:Show()
  if frame then
    frame:Show()
    return
  end
  
  -- Reset class filter to current player class when GUI is first shown
  selectedClassFilter = nil
  frame = AceGUI:Create("Frame")
  frame:SetTitle("Alt Configurator")
  frame:SetStatusText("Alt Configurator GUI")
  frame:SetLayout("Fill")
  frame:SetWidth(900)
  frame:SetHeight(600)
  frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget); frame = nil; tabs = nil end)

  tabs = AceGUI:Create("TabGroup")
  tabs:SetTabs(self:_composeTabs())
  tabs:SetCallback("OnGroupSelected", SelectTab)
  frame:AddChild(tabs)

  local first
  for _, tab in ipairs(tabs.tabs) do first = tab.value break end
  if first then
    tabs:SelectTab(first)
  end
end

function Gui:Toggle()
  if frame and frame.frame:IsShown() then
    frame:Hide()
  else
    self:Show()
  end
end

function Gui:OnEnable()
  -- Initialize dialog system
  if ns.dialogs then
    ns.dialogs:Initialize()
  end
end

-- Module registration pattern
if ns.addon then
  ns.addon:RegisterModule(Gui.name, Gui)
else
  ns._pendingModuleRegs = ns._pendingModuleRegs or {}
  table.insert(ns._pendingModuleRegs, Gui)
end

-- Expose to namespace
ns.gui = Gui
