if #h>510 then return bad("body exceeds 255 bytes.") end
local n,v=decode(nh),decode(h)
if n:find("%c") then return bad("control byte in name.") end
if seen[n] then return bad("duplicate name.") end
