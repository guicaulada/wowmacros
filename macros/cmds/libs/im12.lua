if v:find("%z") then return bad("NUL byte in macro.") end
local icon
if ih~="" then
local path=decode(ih)
if #path>128 or not path:match("^[%w_]+$") then return bad("invalid icon name.") end
icon=GetFileIDFromPath("Interface/Icons/"..path)
