#cmd savebars
#run {|SAVE|} {|LOUT|}
local b={} for i=1,240 do local a={GetActionInfo(i)} if a[1] then b[i]=a end end _S(b, "sb",_LO.spec, _LO.name)