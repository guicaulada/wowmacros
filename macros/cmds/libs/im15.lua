if not i then needed=needed+1 end
end
if GetNumMacros()+needed>cap then return fail("not enough account macro slots.") end
local made,changed,same=0,0,0
for _,r in ipairs(rows) do
local n,v,icon=r[1],r[2],r[3] local i=find(n)
