-- Commands can return early when protected edits are unavailable.
return function()
    if InCombatLockdown() then
        print("Unavailable in combat.")
        return false
    end
    return true
end
