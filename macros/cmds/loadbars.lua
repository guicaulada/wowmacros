#cmd loadbars
#run {[load]} {[lout]} [[outofcombat]]
local b=_LO.name and _L("sb",_LO.spec,_LO.name) if not b then return print("No saved bars for this loadout.") end
#run [[loadbars1]] [[loadbars2]] [[loadbars3]]
