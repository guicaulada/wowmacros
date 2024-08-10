#cmd loadloadouts
#run {|LOAD|} {|LOUT|}
local l=_L("sl", _LO.spec) if l then for k,v in pairs(l) do PlayerSpellsFrame.TalentsFrame:ImportLoadout(v, k) end end
