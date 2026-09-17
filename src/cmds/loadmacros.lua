local loadout = wm.lib("lout")()
if not wm.lib("outofcombat")() then return end
local saved = wm.lib("load")("sm", loadout.class)
if not saved then return print("No saved macros.") end

local keys = {}
for index, macro in pairs(saved) do
    if type(index) ~= "number" or type(macro) ~= "table" then
        return print("Invalid macro snapshot.")
    end
    keys[#keys + 1] = index
end
table.sort(keys)
if #keys > 18 then return print("Too many saved macros.") end
for _, index in ipairs(keys) do
    local macro = saved[index]
    if type(macro[1]) ~= "string" or #macro[1] < 1 or #macro[1] > 16
        or type(macro[3]) ~= "string" or #macro[3] > 255
        or not (type(macro[2]) == "string" or type(macro[2]) == "number") then
        return print("Invalid macro snapshot.")
    end
end

-- Only character macros are replaced; the account-wide runtime stays installed.
for index = 138, 121, -1 do DeleteMacro(index) end
for _, index in ipairs(keys) do
    local macro = saved[index]
    if not CreateMacro(macro[1], macro[2], macro[3], true) then
        return print("Macro restore failed: " .. macro[1])
    end
end
