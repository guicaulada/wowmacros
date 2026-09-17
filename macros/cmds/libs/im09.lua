local function decode(h) return (h:gsub("..",function(x) return string.char(tonumber(x,16)) end)) end
for line in (body.."\n"):gmatch("(.-)\n") do
local nh,ih,h=line:match("^(%x+):(%x*):(%x*)$")
