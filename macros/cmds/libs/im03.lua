local s=CreateFrame("ScrollFrame",nil,f,"UIPanelScrollFrameTemplate")
s:SetPoint("TOPLEFT",16,-40) s:SetPoint("BOTTOMRIGHT",-34,60)
local e=CreateFrame("EditBox",nil,s)
f.Input=e e:SetWidth(560) e:SetHeight(320) e:SetMultiLine(true)
