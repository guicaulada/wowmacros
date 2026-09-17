-- Split at the final whitespace-delimited token so macro names may contain spaces.
if not wm.lib("outofcombat")() then return end
local name, icon = msg:match("^%s*(.-)%s+(%S+)%s*$")
if not name or name == "" or not GetMacroInfo(name) or (tonumber(icon) and tonumber(icon) <= 0) then
    return print("Usage: /macroicon <existing macro name> <icon name or ID>")
end
EditMacro(name, nil, tonumber(icon) or icon)
