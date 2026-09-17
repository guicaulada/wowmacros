if v<p then s:SetVerticalScroll(v) elseif v+h>p+s:GetHeight() then s:SetVerticalScroll(v+h-s:GetHeight()) end
end)
local b=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
b:SetSize(100,24) b:SetPoint("BOTTOMRIGHT",-16,16) b:SetText("Import")
