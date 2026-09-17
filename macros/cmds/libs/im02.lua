f.TitleText:SetText("Import account macros")
f:SetMovable(true) f:EnableMouse(true) f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart",f.StartMoving) f:SetScript("OnDragStop",f.StopMovingOrSizing)
