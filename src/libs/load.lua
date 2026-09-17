-- Read a path from account-wide saved data.
return function(...)
    local value = Blizzard_Console_SavedVars
    for _, key in ipairs({...}) do
        if type(value) ~= "table" then return nil end
        value = value[key]
    end
    return value
end
