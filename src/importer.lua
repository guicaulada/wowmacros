-- Expanded by the command engine. The generator packs this into <=255-byte helpers.
local f=WoWMacrosImport
if f then f:Show() f.Input:SetFocus() return end
f=CreateFrame("Frame",nil,UIParent,"BasicFrameTemplateWithInset")
WoWMacrosImport=f
f:SetSize(620,440) f:SetPoint("CENTER") f:SetFrameStrata("DIALOG")
f.TitleText:SetText("Import account macros")
f:SetMovable(true) f:EnableMouse(true) f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart",f.StartMoving) f:SetScript("OnDragStop",f.StopMovingOrSizing)
local s=CreateFrame("ScrollFrame",nil,f,"UIPanelScrollFrameTemplate")
s:SetPoint("TOPLEFT",16,-40) s:SetPoint("BOTTOMRIGHT",-34,60)
local e=CreateFrame("EditBox",nil,s)
f.Input=e e:SetWidth(560) e:SetHeight(320) e:SetMultiLine(true)
e:SetFontObject(ChatFontNormal) e:SetAutoFocus(false) e:SetMaxLetters(0)
s:SetScrollChild(e)
e:SetScript("OnEscapePressed",function() e:ClearFocus() f:Hide() end)
e:SetScript("OnCursorChanged",function(_,x,y,w,h)
local v=-y local p=s:GetVerticalScroll()
if v<p then s:SetVerticalScroll(v) elseif v+h>p+s:GetHeight() then s:SetVerticalScroll(v+h-s:GetHeight()) end
end)
local b=CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
b:SetSize(100,24) b:SetPoint("BOTTOMRIGHT",-16,16) b:SetText("Import")
local t=f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
t:SetPoint("BOTTOMLEFT",16,20) t:SetText("Paste a WOWMACROS3 bundle, then click Import.")
b:SetScript("OnClick",function()
local function fail(m) print("Import: "..m) end
if InCombatLockdown() then return fail("leave combat first.") end
local raw=e:GetText():gsub("\r\n","\n")
local count,body=raw:match("^WOWMACROS3 (%d+)\n(.*)\nEND%s*$")
if not count then return fail("expected a complete WOWMACROS3 bundle.") end
local cap=Constants and Constants.MacroConsts and Constants.MacroConsts.MAX_ACCOUNT_MACROS or 120
local rows,seen={},{}
local function bad(m) return fail("entry "..(#rows+1)..": "..m) end
local function decode(h) return (h:gsub("..",function(x) return string.char(tonumber(x,16)) end)) end
for line in (body.."\n"):gmatch("(.-)\n") do
local nh,ih,h=line:match("^(%x+):(%x*):(%x*)$")
if not nh then return bad("expected hex name:icon:body; paste the latest bundle.") end
if #nh%2~=0 or #ih%2~=0 or #h%2~=0 then return bad("incomplete hex data.") end
if #nh>32 then return bad("name exceeds 16 bytes.") end
if #h>510 then return bad("body exceeds 255 bytes.") end
local n,v=decode(nh),decode(h)
if n:find("%c") then return bad("control byte in name.") end
if seen[n] then return bad("duplicate name.") end
if v:find("%z") then return bad("NUL byte in macro.") end
local icon
if ih~="" then
local path=decode(ih)
if #path>128 or not path:match("^[%w_]+$") then return bad("invalid icon name.") end
icon=GetFileIDFromPath("Interface/Icons/"..path)
if not icon or icon<=0 then return bad("icon not found: "..path) end
end
rows[#rows+1]={n,v,icon} seen[n]=true
end
if #rows~=tonumber(count) or #rows==0 or #rows>cap then return fail("invalid entry count.") end
local function find(n)
local found
for i=1,GetNumMacros() do if GetMacroInfo(i)==n then if found then return false end found=i end end
return found
end
local needed=0
for _,r in ipairs(rows) do
local i=find(r[1])
if i==false then return fail("ambiguous account macro: "..r[1]) end
if not i then needed=needed+1 end
end
if GetNumMacros()+needed>cap then return fail("not enough account macro slots.") end
local made,changed,same=0,0,0
for _,r in ipairs(rows) do
local n,v,icon=r[1],r[2],r[3] local i=find(n)
local old=i and {GetMacroInfo(i)} or {}
if old[1]==n and old[3]==v and (not icon or old[2]==icon) then same=same+1 else
local ok,err
if i then ok,err=pcall(EditMacro,i,nil,icon,v) else ok,err=pcall(CreateMacro,n,icon or 134400,v,false) end
if not ok then return fail("stopped at "..n..": "..tostring(err).."; earlier changes remain.") end
local j=find(n)
if not j or GetMacroInfo(j)~=n or select(3,GetMacroInfo(j))~=v or (icon and select(2,GetMacroInfo(j))~=icon) then return fail("could not write "..n.."; earlier changes remain.") end
if i then changed=changed+1 else made=made+1 end
end
end
print("Imported:",made,"created,",changed,"updated,",same,"unchanged. Click {cmds} to register commands.")
e:ClearFocus() f:Hide()
end)
f:Show() e:SetFocus()
