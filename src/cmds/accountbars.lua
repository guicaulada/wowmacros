-- Shared action-bar layout. HS/TRNK1/TRNK2 are user-owned macros.
-- Mount shortcuts are user-managed; leave their action-bar slots untouched.
local bars = {
    macros = {[157] = "HS", [152] = "TRNK1", [153] = "TRNK2"},
    items = {[158] = 140192, [159] = 110560},
    spells = {
        [160] = 460905, [163] = 818, [164] = "Cooking", [165] = "Fishing",
        [166] = 271990, [167] = 80451, [168] = 195127, [121] = 372608,
        [122] = 372610, [123] = 361584, [124] = 425782, [125] = 403092, [126] = 374990,
    },
}
local primary, secondary = GetProfessions()
if primary and secondary then
    local first, second = GetProfessionInfo(primary), GetProfessionInfo(secondary)
    for slot, name in pairs({[161] = first, [162] = second}) do
        bars.spells[slot] = name .. " Journal"
        C_Spell.PickupSpell(name)
        PlaceAction(slot)
        ClearCursor()
    end
end
for slot, name in pairs(bars.macros) do
    PickupMacro(name)
    PlaceAction(slot)
    ClearCursor()
end
for slot, id in pairs(bars.items) do
    PickupItem(id)
    PlaceAction(slot)
    ClearCursor()
end
for slot, spell in pairs(bars.spells) do
    C_Spell.PickupSpell(spell)
    PlaceAction(slot)
    ClearCursor()
end
