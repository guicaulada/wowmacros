-- Read current character state when called, rather than caching a loadout.
return function()
    local talents = C_ClassTalents
    local spec = PlayerUtil.GetCurrentSpecID()
    local id = talents.GetLastSelectedSavedConfigID(spec)
    local config = id and C_Traits.GetConfigInfo(id)
    return {
        class = UnitClass("player"),
        spec = spec,
        name = config and config.name,
        configs = talents.GetConfigIDsBySpecID(spec),
    }
end
