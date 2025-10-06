local ADDON_NAME, ns = ...
local addon = ns.addon

-- Simple GUI Testing Module
local GuiTesting = {}
GuiTesting.name = "GuiTesting"

-- Locals
local AceGUI = LibStub and LibStub("AceGUI-3.0")
local frame

local function buildContent(container)
  container:ReleaseChildren()
  local label = AceGUI:Create("Label")
  label:SetText("GuiTesting Module\n\nThis is a barebones AceGUI test window. Add widgets here to experiment.")
  label:SetFullWidth(true)
  container:AddChild(label)

  local btn = AceGUI:Create("Button")
  btn:SetText("Print Hello")
  btn:SetWidth(140)
  btn:SetCallback("OnClick", function()
    print("GuiTesting: Hello from test button.")
  end)
  container:AddChild(btn)
end

function GuiTesting:Show()
  if frame then frame:Show(); return end
  if not AceGUI then
    print("GuiTesting: AceGUI not available (load order issue?)")
    return
  end
  frame = AceGUI:Create("Frame")
  frame:SetTitle("AltConfig GUI Testing")
  frame:SetStatusText("Experimental UI sandbox")
  frame:SetLayout("Fill")
  frame:SetWidth(500)
  frame:SetHeight(400)
  frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget); frame = nil end)

  local container = AceGUI:Create("SimpleGroup")
  container:SetFullWidth(true)
  container:SetFullHeight(true)
  container:SetLayout("List")
  frame:AddChild(container)

  buildContent(container)
end

function GuiTesting:Toggle()
  if frame and frame.frame:IsShown() then
    frame:Hide()
  else
    self:Show()
  end
end

function GuiTesting:OnEnable()
  -- Optional initial actions when module enables
end

-- Optional slash command for quick access (will only register once)
SLASH_ALTCONFIGGUITEST1 = "/acgt"
SlashCmdList["ALTCONFIGGUITEST"] = function()
  GuiTesting:Toggle()
end

-- Register module
if addon then
  addon:RegisterModule(GuiTesting.name, GuiTesting)
else
  ns._pendingModuleRegs = ns._pendingModuleRegs or {}
  table.insert(ns._pendingModuleRegs, GuiTesting)
end

-- Expose for other modules/tests
ns.guiTesting = GuiTesting
