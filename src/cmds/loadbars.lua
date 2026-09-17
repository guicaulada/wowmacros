local load = wm.lib("load")
local loadout = wm.lib("lout")()
if not wm.lib("outofcombat")() then return end
local bars = loadout.name and load("sb", loadout.spec, loadout.name)
if not bars then return print("No saved bars for this loadout.") end

local pickups = {spell = C_Spell.PickupSpell, macro = PickupMacro, item = PickupItem}
local function pick(slot, action)
    ClearCursor()
    local pickup = pickups[action[1]]
    if not pickup then
        print("Unsupported action at slot", slot, action[1])
        return
    end
    pickup(action[2])
    return GetCursorInfo()
end

-- Preflight the entire snapshot before changing any action slots.
for slot, action in pairs(bars) do
    local ok = pick(slot, action)
    ClearCursor()
    if not ok then return print("Cannot restore slot", slot, "No bars changed.") end
end
for slot = 1, 240 do
    local action = bars[slot]
    if action then
        if not pick(slot, action) then
            ClearCursor()
            return print("Restore stopped at slot", slot)
        end
        PlaceAction(slot)
    else
        ClearCursor()
        PickupAction(slot)
    end
    ClearCursor()
end
