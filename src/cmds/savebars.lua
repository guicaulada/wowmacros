-- Replace the loadout snapshot, omitting empty slots so removed actions do not linger.
local loadout = wm.lib("lout")()
if not loadout.name then return print("Select a saved loadout first.") end
local bars = {}
for slot = 1, 240 do
    local action = {GetActionInfo(slot)}
    if action[1] then
        bars[slot] = action
        if action[1] == "macro" then action[2] = GetActionText(slot) end
    end
end
wm.lib("save")(bars, "sb", loadout.spec, loadout.name)
