#cmd savemacros
#run {[save]} {[lout]}
local b={} for i=121,138 do local m={GetMacroInfo(i)} if m[1] then if strfind(m[3],"#showtooltip") then m[2]=134400 end b[i]=m end end _S(b,"sm",_LO.class)
