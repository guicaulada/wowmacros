local _DB=Blizzard_Console_SavedVars
local function _L(...) local args={...} local l=_DB for i,k in ipairs(args) do if i == #args then return l[k] end l=l[k] or {} end end
