for i=1,240 do local a=b[i] if a then if not pick(i,a) then ClearCursor() return print("Restore stopped at slot",i) end PlaceAction(i) else ClearCursor() PickupAction(i) end ClearCursor() end
