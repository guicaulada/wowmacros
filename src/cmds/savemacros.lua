-- Replace this class's character-macro snapshot. Use the question-mark icon for
-- #showtooltip bodies so WoW can resolve the displayed icon after restoration.
local loadout = wm.lib("lout")()
local macros = {}
for index = 121, 138 do
    local macro = {GetMacroInfo(index)}
    if macro[1] then
        if strfind(macro[3], "#showtooltip") then macro[2] = 134400 end
        macros[index] = macro
    end
end
wm.lib("save")(macros, "sm", loadout.class)
