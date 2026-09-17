if not icon or icon<=0 then return bad("icon not found: "..path) end
end
rows[#rows+1]={n,v,icon} seen[n]=true
end
if #rows~=tonumber(count) or #rows==0 or #rows>cap then return fail("invalid entry count.") end
local function find(n)
local found
