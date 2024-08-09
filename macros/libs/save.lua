local _DB=Blizzard_Console_SavedVars
local function _S(v, ...) local args={...} local s=_DB for i,k in ipairs(args) do s[k] = s[k] or {} if i == #args then s[k]=v end s=s[k] end end
