local f=WoWMacrosImport
if f then f:Show() f.Input:SetFocus() return end
f=CreateFrame("Frame",nil,UIParent,"BasicFrameTemplateWithInset")
WoWMacrosImport=f
f:SetSize(620,440) f:SetPoint("CENTER") f:SetFrameStrata("DIALOG")
