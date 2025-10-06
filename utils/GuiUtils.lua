local ADDON_NAME, ns = ...

-- WoW API forward declarations
-- luacheck: globals C_Timer

local GuiUtils = {}

-- Create alternating row background
function GuiUtils:CreateRowBackground(row, isEvenRow)
  if not row or not row.frame then return end
  
  if not row.frame.bg then
    row.frame.bg = row.frame:CreateTexture(nil, "BACKGROUND")
    -- Fill the entire row background
    row.frame.bg:SetPoint("TOPLEFT", row.frame, "TOPLEFT", 0, 0)
    row.frame.bg:SetPoint("BOTTOMRIGHT", row.frame, "BOTTOMRIGHT", 0, 0)
    -- Set a lower strata to ensure it stays behind content
    row.frame.bg:SetDrawLayer("BACKGROUND", -1)
  end
  
  if isEvenRow then
    -- Even rows - darker background
    row.frame.bg:SetColorTexture(0.2, 0.2, 0.3, 0.6) -- Darker blue-tinted with higher opacity
  else
    -- Odd rows - light background
    row.frame.bg:SetColorTexture(0.1, 0.1, 0.1, 0.2) -- Very light dark background
  end
  
  row.frame.bg:Show()
end

-- Apply row-matching background color to buttons
function GuiUtils:ApplyRowColorToButton(button, isEvenRow)
  if not button or not button.frame then return end
  
  -- Use a small delay to ensure button is fully rendered
  if C_Timer and C_Timer.After then
    C_Timer.After(0.02, function()
      if button.frame then
        -- Create or update button background
        if not button.frame.rowBg then
          button.frame.rowBg = button.frame:CreateTexture(nil, "BACKGROUND")
          -- Position background to fill button area
          button.frame.rowBg:SetPoint("TOPLEFT", button.frame, "TOPLEFT", 2, -2)
          button.frame.rowBg:SetPoint("BOTTOMRIGHT", button.frame, "BOTTOMRIGHT", -2, 2)
          button.frame.rowBg:SetDrawLayer("BACKGROUND", 0)
        end
        
        if isEvenRow then
          -- Even rows - darker background (match row color but slightly lighter for buttons)
          button.frame.rowBg:SetColorTexture(0.25, 0.25, 0.35, 0.7)
        else
          -- Odd rows - lighter background (match row color but slightly more visible for buttons)
          button.frame.rowBg:SetColorTexture(0.15, 0.15, 0.15, 0.4)
        end
        
        button.frame.rowBg:Show()
      end
    end)
  end
end

-- Reset scroll position to top
function GuiUtils:ResetScrollPosition(scroll)
  local function resetScroll()
    if scroll and scroll.scrollframe and scroll.scrollframe.SetVerticalScroll then 
      scroll.scrollframe:SetVerticalScroll(0) 
    end
    if scroll and scroll.SetScroll then 
      pcall(function() scroll:SetScroll(0) end) 
    end
  end
  
  resetScroll()
  if C_Timer and C_Timer.After then 
    C_Timer.After(0, resetScroll)
    C_Timer.After(0.05, resetScroll) 
  end
end

-- Create a standard button with consistent sizing
function GuiUtils:CreateButton(text, width, callback)
  local AceGUI = LibStub and LibStub("AceGUI-3.0")
  if not AceGUI then return nil end
  
  local button = AceGUI:Create("Button")
  button:SetText(text)
  button:SetWidth(width)
  if callback then
    button:SetCallback("OnClick", callback)
  end
  return button
end

-- Create a standard label with class coloring
function GuiUtils:CreateClassColoredLabel(text, width, className)
  local AceGUI = LibStub and LibStub("AceGUI-3.0")
  if not AceGUI then return nil end
  
  local label = AceGUI:Create("Label")
  
  if className and ns.classColors then
    local coloredText = ns.classColors:FormatClassText(text, className)
    label:SetText(coloredText)
  else
    label:SetText(text)
  end
  
  if width then
    label:SetWidth(width)
  end
  
  return label
end

-- Format layout display text with timestamps and class info
function GuiUtils:FormatLayoutDisplayText(key, layout)
  local classSpecPart = ""
  
  if ns.classColors then
    classSpecPart = ns.classColors:GetClassSpecText(layout)
  end
  
  local className = nil
  if ns.classColors then
    className = ns.classColors:GetClassName(layout, key)
  end
  
  local baseText = string.format("%s%s - %s", 
    key, classSpecPart, date("%m-%d %H:%M", layout.capturedAt))
  
  if className and ns.classColors then
    return ns.classColors:FormatClassText(baseText, className)
  else
    return baseText
  end
end

-- Expose to namespace
ns.guiUtils = GuiUtils