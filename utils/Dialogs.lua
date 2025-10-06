local ADDON_NAME, ns = ...

-- WoW API forward declarations
-- luacheck: globals StaticPopupDialogs StaticPopup_Show YES NO OKAY CANCEL

local Dialogs = {}

-- Initialize all dialog definitions
function Dialogs:Initialize()
  -- Apply action bar layout confirmation
  if not StaticPopupDialogs["ALTCONFIG_APPLY_ACTIONBARS"] then
    StaticPopupDialogs["ALTCONFIG_APPLY_ACTIONBARS"] = {
      text = "Apply action bar layout '%s'? This will overwrite your current action bars.",
      button1 = YES, 
      button2 = NO,
      OnAccept = function() 
        if ns.actionBarManager then 
          ns.actionBarManager:ApplyActionBarLayout(ns.dialogs._pendingApplyKey) 
        end 
      end,
      timeout = 0, 
      whileDead = true, 
      hideOnEscape = true, 
      preferredIndex = 3,
    }
  end

  -- Rename layout dialog
  if not StaticPopupDialogs["ALTCONFIG_RENAME_LAYOUT"] then
    StaticPopupDialogs["ALTCONFIG_RENAME_LAYOUT"] = {
      text = "Enter new name for layout:", 
      button1 = OKAY, 
      button2 = CANCEL,
      hasEditBox = true, 
      maxLetters = 64,
      OnAccept = function(selfPopup)
        local newName = selfPopup.EditBox:GetText():gsub("^%s+", ""):gsub("%s+$", "")
        if newName == "" then return end
        local layouts = ns.db.profile.actionBars.layouts
        if layouts[newName] and newName ~= ns.dialogs._pendingRenameKey then 
          print("AltConfig: A layout named '"..newName.."' already exists.") 
          return 
        end
        if not layouts[ns.dialogs._pendingRenameKey] then 
          print("AltConfig: Original layout missing for rename.") 
          return 
        end
        layouts[newName] = layouts[ns.dialogs._pendingRenameKey]
        if newName ~= ns.dialogs._pendingRenameKey then 
          layouts[ns.dialogs._pendingRenameKey] = nil 
        end
        ns.dialogs._pendingRenameKey = nil
        if ns.dialogs._onRenameComplete then
          ns.dialogs._onRenameComplete(newName)
        end
        print("AltConfig: Renamed layout to '"..newName.."'.")
      end,
      OnCancel = function() 
        ns.dialogs._pendingRenameKey = nil 
      end,
      EditBoxOnEnterPressed = function(selfBox) 
        selfBox:GetParent().button1:Click() 
      end,
      timeout = 0, 
      whileDead = true, 
      hideOnEscape = true, 
      preferredIndex = 3,
    }
  end

  -- Delete layout confirmation
  if not StaticPopupDialogs["ALTCONFIG_DELETE_LAYOUT"] then
    StaticPopupDialogs["ALTCONFIG_DELETE_LAYOUT"] = {
      text = "Delete layout '%s'? This cannot be undone.", 
      button1 = YES, 
      button2 = NO,
      OnAccept = function(self, data)
        local keyToDelete = data
        local layouts = ns.db.profile.actionBars.layouts
        if layouts[keyToDelete] then 
          layouts[keyToDelete] = nil 
          print("AltConfig: Deleted layout '"..keyToDelete.."'.") 
          if ns.dialogs._onDeleteComplete then
            ns.dialogs._onDeleteComplete()
          end
        end
      end,
      timeout = 0, 
      whileDead = true, 
      hideOnEscape = true, 
      preferredIndex = 3,
    }
  end

  -- Copy layout data dialog
  if not StaticPopupDialogs["ALTCONFIG_COPY_LAYOUT"] then
    StaticPopupDialogs["ALTCONFIG_COPY_LAYOUT"] = {
      text = "Layout data (select all and copy):",
      button1 = "Close",
      hasEditBox = true,
      editBoxWidth = 500,
      OnShow = function(self)
        if self.EditBox and ns.dialogs._pendingCopyText then
          -- Use fixed dialog size
          local dialogWidth = 600
          local dialogHeight = 350
          
          self:SetWidth(dialogWidth)
          self:SetHeight(dialogHeight)
          
          -- Create scroll frame if it doesn't exist
          if not self.ScrollFrame then
            local scrollFrame = CreateFrame("ScrollFrame", nil, self, "UIPanelScrollFrameTemplate")
            self.ScrollFrame = scrollFrame
            
            -- Position scroll frame
            scrollFrame:SetPoint("TOPLEFT", self.Text, "BOTTOMLEFT", 0, -10)
            scrollFrame:SetPoint("BOTTOMRIGHT", self.button1, "TOPRIGHT", -30, 10)
            
            -- Create edit box for scroll frame
            local editBox = CreateFrame("EditBox", nil, scrollFrame)
            editBox:SetMultiLine(true)
            editBox:SetAutoFocus(false)
            editBox:SetFontObject("ChatFontNormal")
            editBox:SetWidth(scrollFrame:GetWidth())
            editBox:SetMaxLetters(0)
            editBox:EnableMouse(true)
            editBox:SetScript("OnEscapePressed", function() self:Hide() end)
            
            scrollFrame:SetScrollChild(editBox)
            self.ScrollEditBox = editBox
          end
          
          -- Hide the original edit box since we're using our scroll frame
          if self.EditBox then
            self.EditBox:Hide()
          end
          
          -- Set the text in our scroll edit box
          if self.ScrollEditBox then
            self.ScrollEditBox:SetText(ns.dialogs._pendingCopyText)
            self.ScrollEditBox:SetCursorPosition(0)
            self.ScrollEditBox:HighlightText()
            self.ScrollEditBox:SetFocus()
            
            -- Update scroll child size based on text
            local textHeight = self.ScrollEditBox:GetStringHeight()
            self.ScrollEditBox:SetHeight(math.max(textHeight + 20, self.ScrollFrame:GetHeight()))
          end
          
          -- Make the dialog movable and center it
          self:SetMovable(true)
          self:EnableMouse(true)
          self:RegisterForDrag("LeftButton")
          self:SetScript("OnDragStart", function(self) self:StartMoving() end)
          self:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
          
          -- Center the dialog on screen
          self:ClearAllPoints()
          self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
      end,
      timeout = 0, 
      whileDead = true, 
      hideOnEscape = true, 
      preferredIndex = 3,
    }
  end
end

-- Show apply confirmation dialog
function Dialogs:ShowApplyDialog(layoutKey)
  self._pendingApplyKey = layoutKey
  StaticPopup_Show("ALTCONFIG_APPLY_ACTIONBARS", layoutKey)
end

-- Show rename dialog
function Dialogs:ShowRenameDialog(layoutKey, onComplete)
  self._pendingRenameKey = layoutKey
  self._onRenameComplete = onComplete
  local dlg = StaticPopup_Show("ALTCONFIG_RENAME_LAYOUT")
  if dlg and dlg.EditBox then 
    dlg.EditBox:SetText(layoutKey) 
    dlg.EditBox:HighlightText() 
  end
end

-- Show delete confirmation dialog
function Dialogs:ShowDeleteDialog(layoutKey, onComplete)
  self._onDeleteComplete = onComplete
  StaticPopup_Show("ALTCONFIG_DELETE_LAYOUT", layoutKey, nil, layoutKey)
end

-- Show copy data dialog
function Dialogs:ShowCopyDialog(layoutKey, layoutData)
  local serializedData
  if ns.serialization then
    serializedData = ns.serialization:SerializeTable(layoutData)
  else
    -- Fallback inline serialization if module not available
    local function serializeTable(t, indent)
      indent = indent or 0
      local spaces = string.rep("  ", indent)
      local result = "{\n"
      
      for k, v in pairs(t) do
        local keyStr = type(k) == "string" and string.format('["%s"]', k) or string.format("[%s]", tostring(k))
        
        if type(v) == "table" then
          result = result .. spaces .. "  " .. keyStr .. " = " .. serializeTable(v, indent + 1) .. ",\n"
        elseif type(v) == "string" then
          result = result .. spaces .. "  " .. keyStr .. " = \"" .. v .. "\",\n"
        else
          result = result .. spaces .. "  " .. keyStr .. " = " .. tostring(v) .. ",\n"
        end
      end
      
      result = result .. spaces .. "}"
      return result
    end
    serializedData = serializeTable(layoutData)
  end
  
  self._pendingCopyText = string.format("-- AltConfig Layout Data for: %s\nlocal layoutData = %s", 
    layoutKey, serializedData)
  StaticPopup_Show("ALTCONFIG_COPY_LAYOUT")
  print("AltConfig: Layout data ready to copy for '"..layoutKey.."'.")
end

-- Expose to namespace
ns.dialogs = Dialogs