-- Scan once and choose uniformly among collected mounts of the requested types.
return function(types, excludeActive)
    local journal = C_MountJournal
    local candidates = {}
    for _, id in ipairs(journal.GetMountIDs()) do
        local info = {journal.GetMountInfoByID(id)}
        local kind = select(5, journal.GetMountInfoExtraByID(id))
        if info[11] and not (excludeActive and info[4]) and types[kind] then
            candidates[#candidates + 1] = id
        end
    end
    if #candidates == 0 then
        return print("No matching mount.")
    end
    journal.SummonByID(candidates[random(#candidates)])
end
