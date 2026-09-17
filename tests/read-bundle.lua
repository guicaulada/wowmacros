-- Decode the shipped bundle independently of the in-game importer. Tests use
-- these exact bytes without materializing one file per stored macro.
local file = assert(io.open("generated/macros.txt", "rb"))
local text = file:read("*a")
file:close()
local count, rows = text:match("^WOWMACROS3 (%d+)\n(.*)\nEND\n$")
assert(count, "Malformed generated bundle")
local function decode(hex)
  assert(#hex % 2 == 0, "Incomplete hex byte")
  return (hex:gsub("..", function(pair) return string.char(assert(tonumber(pair, 16))) end))
end
local bodies, total = {}, 0
for row in (rows .. "\n"):gmatch("(.-)\n") do
  local name, icon, body = row:match("^(%x+):(%x*):(%x*)$")
  assert(name, "Malformed generated record")
  name = decode(name)
  assert(not bodies[name], "Duplicate generated name")
  bodies[name] = decode(body)
  total = total + 1
end
assert(total == tonumber(count), "Generated count mismatch")
return bodies
