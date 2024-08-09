#cmd way
local x,y=string.match(msg,"^%s*([%d%.]+)[,%s]+([%d%.]+)") local m=C_Map.GetBestMapForUnit("player") C_Map.SetUserWaypoint(UiMapPoint.CreateFromVector2D(m,CreateVector2D(x/100,y/100)))
