-- @catalog
-- The compiler replaces the directive above with the generated source catalog.
-- Register every command only after all command chunks have compiled successfully.
local runtime = {commands = {}}
local cache = {}
local loading = {}

-- Descriptors contain a chunk prefix, count, and optional first-chunk name.
-- Strip only whitespace outside the ! payload markers added by the compiler.
-- WoW may append a newline when persisting macro text across game sessions.
-- Join payloads without separators: boundaries can fall inside strings/tokens.
local function read(parts)
    local chunks = {}
    for index = 1, parts[2] do
        local name = index == 1 and parts[3] or nil
        name = name or string.format("~3.%s.%03d", parts[1], index)
        local body = assert(GetMacroBody(name), "Missing macro: " .. name)
        chunks[index] = assert(body:match("^%s*!(.*)!%s*$"), "Invalid chunk: " .. name)
    end
    return table.concat(chunks)
end

-- Cache returned values, not changing game state. Clear the loading guard even
-- when a factory fails so a later attempt can recover.
function runtime.lib(name)
    if cache[name] ~= nil then return cache[name] end
    assert(not loading[name], "Circular library: " .. name)
    local parts = assert(catalog.libs[name], "Unknown library: " .. name)
    local factory = assert(loadstring("return function(wm) " .. read(parts) .. " end"))()
    loading[name] = true
    local ok, value = pcall(factory, runtime)
    loading[name] = nil
    assert(ok, value)
    assert(value ~= nil, "Library returned nil: " .. name)
    cache[name] = value
    return value
end

-- Compile everything first so a missing chunk cannot leave half the commands
-- newly registered. Each callback captures this runtime and its library cache.
local commands = {}
for name, parts in pairs(catalog.cmds) do
    commands[name] = assert(loadstring("return function(msg,wm) " .. read(parts) .. " end"))()
end
for name, callback in pairs(commands) do
    local command = callback
    local key = "WOWMACROS_" .. name
    _G["SLASH_" .. key .. "1"] = "/" .. name
    SlashCmdList[key] = function(msg) return command(msg, runtime) end
    runtime.commands[#runtime.commands + 1] = "/" .. name
end
-- Expose only commands registered by this runtime, in a stable display order.
table.sort(runtime.commands)
WoWMacros = runtime
print("CMDS OK!")
