if InCombatLockdown() then return fail("leave combat first.") end
local raw=e:GetText():gsub("\r\n","\n")
local count,body=raw:match("^WOWMACROS3 (%d+)\n(.*)\nEND%s*$")
if not count then return fail("expected a complete WOWMACROS3 bundle.") end
