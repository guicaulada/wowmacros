for i=1,GetNumMacros() do if GetMacroInfo(i)==n then if found then return false end found=i end end
return found
end
local needed=0
for _,r in ipairs(rows) do
local i=find(r[1])
if i==false then return fail("ambiguous account macro: "..r[1]) end
