#cmd saveloadout
#run {|SAVE|}
local p=PlayerUtil.GetCurrentSpecID() _S(PlayerSpellsFrame.TalentsFrame:GetLoadoutExportString(), "sl", p, C_Traits.GetConfigInfo(C_ClassTalents.GetLastSelectedSavedConfigID(p)).name)
