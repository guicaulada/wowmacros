#cmd loadmacros
#run {|LOAD|} {|LOUT|}
local l=_L("sm", _LO.class) if l then for _,m in pairs(l) do CreateMacro(m[1], m[2], m[3], true) end end
