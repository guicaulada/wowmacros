-- Replace the value at a path, creating missing parent tables.
return function(value, ...)
    local keys = {...}
    local data = Blizzard_Console_SavedVars
    for index, key in ipairs(keys) do
        if index == #keys then
            data[key] = value
        else
            data[key] = data[key] or {}
            data = data[key]
        end
    end
end
