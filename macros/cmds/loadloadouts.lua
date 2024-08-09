#cmd loadloadouts
#run {|LOAD|}
local l=_L("sl", PlayerUtil.GetCurrentSpecID()) if l then for k,v in pairs(l) do PlayerSpellsFrame.TalentsFrame:ImportLoadout(v, k) end end
