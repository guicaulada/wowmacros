#cmd savemacros
#run {|SAVE|} {|LOUT|}
for i=121,138 do local m={GetMacroInfo(i)} if m[1] then if strfind(m[3], "#showtooltip") then m[2]=134400 end _S(m,"sm",_LO.class,i) end end
