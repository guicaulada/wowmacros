for i,a in pairs(b) do local ok=pick(i,a) ClearCursor() if not ok then return print("Cannot restore slot",i,"No bars changed.") end end
