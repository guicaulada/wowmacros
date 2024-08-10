#cmd savemacros
#run {|SAVE|} {|LOUT|}
for i=121,138 do local m={GetMacroInfo(i)} if m[1] then _S(m,"sm",_LO.class,i) end end
