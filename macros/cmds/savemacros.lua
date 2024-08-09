#cmd savemacros
#run {|SAVE|}
for i=121,138 do local m={GetMacroInfo(i)} if m[1] then _S(m, "sm", UnitClass("player"), i) end end
