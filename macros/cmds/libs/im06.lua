local t=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
t:SetPoint("BOTTOMLEFT",16,20) t:SetText("Paste a WOWMACROS3 bundle, then click Import.")
b:SetScript("OnClick",function()
local function fail(m) print("Import: "..m) end
