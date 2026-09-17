#cmd loadmacros
#run {[load]} {[lout]} [[outofcombat]]
local l=_L("sm",_LO.class) if not l then return print("No saved macros.") end
#run [[loadmacros1]] [[macrocheck]] [[loadmacros2]]
