-- Remove the current specialization's saved talent configurations, then enable its starter build.
local loadout = wm.lib("lout")()
for _, id in pairs(loadout.configs) do
    C_ClassTalents.DeleteConfig(id)
end
C_ClassTalents.SetStarterBuildActive(true)
