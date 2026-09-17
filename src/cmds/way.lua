-- Accept percentages separated by spaces or a comma; the map API expects 0–1 coordinates.
local x, y = msg:match("^%s*([%d%.]+)[,%s]+([%d%.]+)%s*$")
x, y = tonumber(x), tonumber(y)
if not x or not y or x < 0 or x > 100 or y < 0 or y > 100 then
    return print("Usage: /way <x> <y> (0-100)")
end
local map = C_Map.GetBestMapForUnit("player")
if not map or not C_Map.CanSetUserWaypointOnMap(map) then
    return print("No waypoint on this map.")
end
C_Map.SetUserWaypoint(UiMapPoint.CreateFromVector2D(map, CreateVector2D(x / 100, y / 100)))
