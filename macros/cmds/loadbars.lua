#cmd loadbars
#run {|LOAD|} {|LOUT|}
local p={spell=C_Spell.PickupSpell, macro=PickupMacro} local b=_L("sb",_LO.spec,_LO.name) if b then for i,a in pairs(b) do ClearCursor() local f=p[a[1]] if f then f(a[2]) PlaceAction(i) end ClearCursor() end end
