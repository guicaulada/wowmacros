-- Delete only account macros using a system prefix. Iterate backward because
-- deleting a macro shifts later indices; this also removes ~1.uninstall itself.
if InCombatLockdown() then return print("Leave combat first.") end
local count = 0
for i = GetNumMacros(), 1, -1 do
    local name = GetMacroInfo(i)
    if name and name:match("^~[123]%.") then
        DeleteMacro(i)
        count = count + 1
    end
end
print("Uninstalled", count, "macros.")
