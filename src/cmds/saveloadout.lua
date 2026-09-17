-- Save the talents UI export under specialization and loadout name.
local loadout = wm.lib("lout")()
wm.lib("save")(
    PlayerSpellsFrame.TalentsFrame:GetLoadoutExportString(),
    "sl", loadout.spec, loadout.name
)
