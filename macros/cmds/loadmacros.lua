#cmd loadmacros
#run {|LOAD|}
local c=UnitClass("player") local l=_L("sm", c) if l then for _,m in pairs(l) do CreateMacro(m[1], m[2], m[3], true) end end
