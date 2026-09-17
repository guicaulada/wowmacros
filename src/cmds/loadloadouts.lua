-- Import saved talent strings for the current specialization. The talents UI must be available.
local loadout = wm.lib("lout")()
local saved = wm.lib("load")("sl", loadout.spec)
if saved then
    for name, data in pairs(saved) do
        PlayerSpellsFrame.TalentsFrame:ImportLoadout(data, name)
    end
end
