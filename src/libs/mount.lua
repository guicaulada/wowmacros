-- Retail mount types. Keep capabilities separate: some mounts can swim and fly.
-- Type reference: https://github.com/xod-wow/LiteMount/blob/main/SpellInfo.lua
local skyriding = {[402] = true, [424] = true, [436] = true,
    [437] = true, [444] = true, [445] = true}
local flying = {[248] = true, [407] = true}
local aquatic = {[231] = true, [232] = true, [254] = true,
    [407] = true, [412] = true}
local ground = {[230] = true, [241] = true, [284] = true, [412] = true}

return function()
    if IsFlying() then return print("Land before changing mounts.") end
    local journal = C_MountJournal
    local swimming = IsSwimming()
    -- advflyable alone is not flight permission: also require a flyable area.
    local advanced = IsAdvancedFlyableArea()
    local trained
    if advanced then
        trained = journal.IsDragonridingUnlocked()
    else
        trained = IsPlayerSpell(90265) or IsPlayerSpell(34090)
            or IsPlayerSpell(34091) or IsPlayerSpell(54197)
    end
    local canFly = IsFlyableArea() and trained
    local faction = ({Horde = 0, Alliance = 1})[UnitFactionGroup("player")]
    local candidates, best = {}, 0
    for _, id in ipairs(journal.GetMountIDs()) do
        local info = {journal.GetMountInfoByID(id)}
        if info[11] and info[5] and not info[4] and not info[10]
            and (not info[8] or info[9] == faction)
            and journal.GetMountUsabilityByID(id, true) then
            local kind = select(5, journal.GetMountInfoExtraByID(id))
            local flies = flying[kind] or skyriding[kind]
            local rank = 0
            if swimming and aquatic[kind] then
                rank = kind == 232 and 5 or 4 -- Vashj'ir seahorse, when usable.
            elseif canFly and flies and (not advanced or (skyriding[kind] and not info[13])) then
                rank = 3
            elseif ground[kind] then
                rank = 2
            elseif flies then
                rank = 1 -- A flying mount can still serve as a ground fallback.
            end
            if rank > best then candidates, best = {}, rank end
            if rank > 0 and rank == best then candidates[#candidates + 1] = id end
        end
    end
    if #candidates == 0 then return print("No usable mount.") end
    journal.SummonByID(candidates[random(#candidates)])
end
