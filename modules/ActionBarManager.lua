local ADDON_NAME, ns = ...

-- WoW API forward declarations
-- luacheck: globals GetActionInfo PickupSpell PickupItem PickupMacro PickupAction PlaceAction ClearCursor CursorHasSpell CursorHasItem CursorHasMacro InCombatLockdown time C_Spell C_Item UnitClass GetSpecialization GetSpecializationInfo

local ActionBarManager = {}
ActionBarManager.name = "ActionBarManager"

-- Capture current action bars to a new layout
function ActionBarManager:CaptureActionBars(nameOverride)
  local store = ns.db.profile.actionBars.layouts
  local key
  if nameOverride then
    key = nameOverride
    if store[key] then
      local base = key
      local n = 2
      while store[base.."-"..n] do n = n + 1 end
      key = base.."-"..n
    end
  else
    local base = ns.utils.characterKey()
    if not store[base] then key = base else
      local n = 2
      while store[base.."-"..n] do n = n + 1 end
      key = base.."-"..n
    end
  end
  
  -- Get current class and spec info
  local _, playerClass = UnitClass("player")
  local specIndex = GetSpecialization and GetSpecialization() or 1
  local specName = "Unknown"
  if GetSpecializationInfo then
    local specID, name = GetSpecializationInfo(specIndex)
    if name then specName = name end
  end
  
  local layout = { 
    capturedAt = time(), 
    playerClass = playerClass,
    specName = specName,
    specIndex = specIndex,
    slots = {} 
  }
  
  for slot=1,120 do
    local actionType, id, subType, spellID = GetActionInfo(slot)
    if actionType then 
      layout.slots[slot] = { type = actionType, id = id, subType = subType, spellID = spellID } 
    end
  end
  
  store[key] = layout
  if ns.debug and ns.debug.info then 
    local slotCount = 0
    for _ in pairs(layout.slots) do slotCount = slotCount + 1 end
    ns.debug:info("Captured action bars to new layout '%s' (%d populated slots)", key, slotCount) 
  end
  print("AltConfig: Captured action bars as new layout '"..key.."'.")
  return key, layout
end

-- Apply a stored layout to the player's action bars
function ActionBarManager:ApplyActionBarLayout(key)
  if not key then return end
  local layout = ns.db.profile.actionBars.layouts[key]
  if not layout then
    print("AltConfig: Layout '"..tostring(key).."' not found.")
    return
  end
  if InCombatLockdown and InCombatLockdown() then
    print("AltConfig: Cannot apply layouts while in combat.")
    return
  end

  local applied, skipped, cleared, matched = 0, 0, 0, 0

  local function pickup(slotData)
    if not slotData or not slotData.type then return false end
    -- Clear any lingering cursor before attempting
    if CursorHasSpell() or CursorHasItem() or CursorHasMacro() then
      ClearCursor()
    end
    local t = slotData.type
    if t == "spell" then
      local sid = slotData.spellID or slotData.id
      if not sid then return false end
      if C_Spell and C_Spell.PickupSpell then
        C_Spell.PickupSpell(sid)
      elseif PickupSpell then
        PickupSpell(sid)
      else
        return false
      end
      return CursorHasSpell()
    elseif t == "item" and slotData.id then
      if C_Item and C_Item.PickupItem then
        C_Item.PickupItem(slotData.id)
      elseif PickupItem then
        PickupItem(slotData.id)
      else
        return false
      end
      return CursorHasItem()
    elseif t == "macro" and slotData.id then
      if PickupMacro then
        PickupMacro(slotData.id)
        return CursorHasMacro()
      end
      return false
    end
    return false
  end

  for slot=1,120 do
    local desired = layout.slots[slot]
    local cType, cId = GetActionInfo(slot)
    if not desired then
      if cType then
        -- Attempt to clear the slot
        local beforeSpell, beforeItem, beforeMacro = CursorHasSpell(), CursorHasItem(), CursorHasMacro()
        if beforeSpell or beforeItem or beforeMacro then
          ClearCursor()
        end
        local clearedSlot = false
        if PickupAction then
          PickupAction(slot)
          if CursorHasSpell() or CursorHasItem() or CursorHasMacro() then
            ClearCursor()
            cleared = cleared + 1
            clearedSlot = true
            if ns.debug and ns.debug.verbose then
              ns.debug:verbose("Cleared extra slot %d (type=%s id=%s)", slot, tostring(cType), tostring(cId))
            end
          end
        end
        if not clearedSlot then
          cleared = cleared + 1
          local msg = string.format("AltConfig: Could not programmatically clear extra slot %d (type=%s id=%s)", slot, tostring(cType), tostring(cId))
          print(msg)
          if ns.debug and ns.debug.warn then
            ns.debug:warn(msg)
          end
        end
      end
    else
      if cType == desired.type and cId == desired.id then
        matched = matched + 1
      else
        local ok = pickup(desired)
        if ok and (CursorHasSpell() or CursorHasItem() or CursorHasMacro()) then
          PlaceAction(slot)
          ClearCursor()
          applied = applied + 1
        else
          skipped = skipped + 1
          local msg = string.format("AltConfig: Could not set slot %d (%s:%s) - source unavailable or pickup failed.", slot, tostring(desired.type), tostring(desired.id))
          print(msg)
          if ns.debug and ns.debug.warn then
            ns.debug:warn(msg)
          end
        end
        if CursorHasSpell() or CursorHasItem() or CursorHasMacro() then
          ClearCursor()
        end
      end
    end
  end

  layout.lastApplied = time()

  if ns.debug and ns.debug.info then
    ns.debug:info("Applied layout '%s': applied=%d matched=%d cleared=%d skipped=%d", key, applied, matched, cleared, skipped)
  end
  print(string.format("AltConfig: Applied layout '%s' (applied %d, matched %d, cleared %d, skipped %d)", key, applied, matched, cleared, skipped))

  return { applied = applied, matched = matched, cleared = cleared, skipped = skipped }
end

function ActionBarManager:OnEnable()
  -- Module initialization if needed
end

-- Module registration
if ns.addon then
  ns.addon:RegisterModule(ActionBarManager.name, ActionBarManager)
else
  ns._pendingModuleRegs = ns._pendingModuleRegs or {}
  table.insert(ns._pendingModuleRegs, ActionBarManager)
end

-- Expose to namespace
ns.actionBarManager = ActionBarManager