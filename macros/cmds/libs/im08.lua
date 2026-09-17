local cap=Constants and Constants.MacroConsts and Constants.MacroConsts.MAX_ACCOUNT_MACROS or 120
local rows,seen={},{}
local function bad(m) return fail("entry "..(#rows+1)..": "..m) end
