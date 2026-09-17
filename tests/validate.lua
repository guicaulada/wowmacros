-- Run from the repository root with Lua 5.1 or LuaJIT.
local manifest = dofile("scripts/manifest.lua")
local function read(path)
  local f = assert(io.open(path, "rb"))
  local body = f:read("*a")
  f:close()
  return body
end
local bodies, paths, commands, storedBodies = {}, {}, {}, {}
local function stored(name) return name end
local largest, largestPath = 0, ""
for _, entry in ipairs(manifest) do
  local name, path = unpack(entry)
  assert(not name:find("|",1,true), "Pipe in macro name: " .. name)
  assert(name==name:lower(), "Macro names must be lowercase: " .. name)
  assert(not bodies[name], "Duplicate macro name: " .. name)
  assert(not paths[path], "Duplicate macro path: " .. path)
  local body = read(path)
  -- Count bytes, including every newline: conservative for non-ASCII text too.
  assert(#body <= 255, path .. " exceeds 255 bytes: " .. #body)
  assert(#name <= 16, "Macro name exceeds 16 bytes: " .. name)
  if #body > largest then largest, largestPath = #body, path end
  bodies[name], paths[path], storedBodies[stored(name)] = body, true, body
end
local listing = assert(io.popen("find macros -type f -name '*.lua'"))
for path in listing:lines() do assert(paths[path], "Missing manifest entry: " .. path) end
listing:close()

local function environment()
  local env = setmetatable({}, {__index = _G})
  env._G = env
  env.gsub, env.strmatch, env.strfind, env.format = string.gsub, string.match, string.find, string.format
  env.GetMacroBody = function(name) return storedBodies[name] end
  env.messages = {}
  env.print = function(...) env.messages[#env.messages + 1] = {...} end
  env.InCombatLockdown = function() return false end
  env.Blizzard_Console_SavedVars = {}
  env.UnitClass = function() return "Mage" end
  env.PlayerUtil = {GetCurrentSpecID = function() return 62 end}
  env.C_ClassTalents = {
    GetLastSelectedSavedConfigID = function() return 1 end,
    GetConfigIDsBySpecID = function() return {1} end,
  }
  env.C_Traits = {GetConfigInfo = function() return {name = "Test"} end}
  return env
end
local function compile(body, env, name)
  local fn = assert(loadstring(body, name))
  return setfenv(fn, env)
end
local env = environment()
compile(bodies["{[run]}"], env)()
for name, body in pairs(bodies) do
  local command, code = body:match("^#cmd%s+(%w+)(.*)")
  if command then
    assert(not commands[command], "Duplicate command: " .. command)
    commands[command] = "return function(msg) " .. env.gsubrun(code) .. " end"
    compile(commands[command], env, name)
  elseif body:match("^/run ") then
    compile(body:sub(6), env, name)
  elseif not name:match("^%[%[") then
    compile(body, env, name)
  end
  -- Literal dependencies used by standalone macros and the engine.
  for dependency in body:gmatch('GetMacroBody%("([^"]+)"%)') do
    assert(storedBodies[dependency], "Missing dependency: " .. dependency)
  end
end
local function command(name, env, msg)
  return compile(assert(commands[name]), env, name)()(msg or "")
end
local tests = 0
local function test(name, fn)
  local ok, err = pcall(fn)
  assert(ok, name .. ": " .. tostring(err))
  tests = tests + 1
  print("PASS " .. name)
end

test("line-scoped includes, multiple libraries and missing dependency diagnostics", function()
  local e = environment()
  e.GetMacroBody = function(k) return ({a = "local a=2", b = "local b=3"})[k] end
  compile(bodies["{[run]}"], e)()
  assert(compile(e.gsubrun("#run a\n#run b\nreturn a+b"), e)() == 5)
  assert(compile(e.gsubrun("#run a b\nreturn a+b"), e)() == 5)
  assert(compile(e.gsubrun("#run a\r\n#run b\r\nreturn a+b"), e)() == 5)
  local ok, err = pcall(e.gsubrun, "#run missing")
  assert(not ok and err:find("Missing macro: missing", 1, true))
  assert(e.gsubrun('print("#run missing")'):find('print("#run missing")', 1, true))
end)

test("actual engine registers every command", function()
  local e = environment()
  e.SlashCmdList = {}
  e.GetMacroBody = function(k)
    return type(k) == "number" and manifest[k] and bodies[manifest[k][1]] or storedBodies[k]
  end
  e.RunScript = function(code) return compile(code, e)() end
  compile(bodies["{cmds}"]:sub(6), e)()
  for name in pairs(commands) do
    assert(type(e.SlashCmdList[name]) == "function", name)
    assert(e["SLASH_" .. name .. "1"] == "/" .. name)
  end
end)

test("mount selection terminates, preserves type filters and handles empty collections", function()
  for _, name in ipairs({"run", "fly"}) do
    local e, collection, summoned = environment(), {}, nil
    e.random = function(n) assert(n > 0); return n end
    e.C_MountJournal = {
      GetMountIDs = function() local t = {}; for i in ipairs(collection) do t[i] = i end; return t end,
      GetMountInfoByID = function(id)
        local m = collection[id]
        return "Mount", nil, nil, m.active, false, nil, nil, nil, nil, nil, m.collected, id
      end,
      GetMountInfoExtraByID = function(id) return nil, nil, nil, nil, collection[id].kind end,
      SummonByID = function(id) summoned = id end,
    }
    -- loadstring in WoW uses the shared global environment.
    e.loadstring = function(s) return compile(s, e) end
    local run = compile(bodies[name]:sub(6), e)
    local function boundedRun()
      debug.sethook(function() error("Unbounded mount selection") end, "", 10000)
      local ok, err = pcall(run)
      debug.sethook()
      assert(ok, err)
    end
    boundedRun()
    assert(not summoned and #e.messages == 1)
    collection = {{kind = 999, collected = true}, {kind = 230, collected = false}}
    boundedRun()
    assert(not summoned and #e.messages == 2)
    collection = {{kind = 230, collected = true}, {kind = 424, collected = true},
                  {kind = 248, collected = true}, {kind = 402, collected = true}}
    boundedRun()
    assert(summoned == (name == "run" and 1 or 4))
    if name == "run" then
      summoned, collection[1].active = nil, true
      boundedRun()
      assert(not summoned)
    end
  end
end)

test("macro snapshots remove stale entries and repeated restores replace character macros only", function()
  local e = environment()
  local current = {{"A", 1, "body A"}, {"B", 2, "#showtooltip\nbody B"}}
  e.GetMacroInfo = function(i) if current[i - 120] then return unpack(current[i - 120]) end end
  e.DeleteMacro = function(i) assert(i >= 121 and i <= 138); if current[i - 120] then table.remove(current, i - 120) end end
  e.CreateMacro = function(n, i, b, character)
    assert(character and #current < 18)
    current[#current + 1] = {n, i, b}
    return 120 + #current
  end
  command("savemacros", e)
  assert(e.Blizzard_Console_SavedVars.sm.Mage[122][2] == 134400)
  current[2] = nil
  command("savemacros", e)
  assert(e.Blizzard_Console_SavedVars.sm.Mage[122] == nil)
  current = {{"Unrelated", 3, "old"}}
  command("loadmacros", e)
  command("loadmacros", e)
  assert(#current == 1 and current[1][1] == "A")
  e.InCombatLockdown = function() return true end
  command("loadmacros", e)
  assert(#current == 1)
  e.InCombatLockdown = function() return false end
  e.Blizzard_Console_SavedVars.sm.Mage = {}
  for i = 1, 19 do e.Blizzard_Console_SavedVars.sm.Mage[i] = {"A", 1, "body"} end
  command("loadmacros", e)
  assert(#current == 1)
  for _, malformed in ipairs({{false, 1, "body"}, {"A", false, "body"}, {"A", 1, 123},
                               {"A", 1, string.rep("x", 256)}}) do
    e.Blizzard_Console_SavedVars.sm.Mage = {[121] = malformed}
    command("loadmacros", e)
    assert(#current == 1 and current[1][1] == "A")
  end
  e.Blizzard_Console_SavedVars.sm.Mage = nil
  command("loadmacros", e)
  assert(#current == 1)
  e.Blizzard_Console_SavedVars.sm.Mage = {}
  command("loadmacros", e)
  assert(#current == 0)
end)

local function barsEnvironment()
  local e, slots, cursor = environment(), {}, nil
  e.C_Spell = {PickupSpell = function(id) if id ~= 999 then cursor = {"spell", id} end end}
  e.PickupMacro = function(id) if id ~= "missing" then cursor = {"macro", id} end end
  e.PickupItem = function(id) cursor = {"item", id} end
  e.ClearCursor = function() cursor = nil end
  e.GetCursorInfo = function() if cursor then return unpack(cursor) end end
  e.PickupAction = function(i) cursor, slots[i] = slots[i], nil end
  e.PlaceAction = function(i) assert(cursor); cursor, slots[i] = slots[i], cursor end
  e.GetActionInfo = function(i) if slots[i] then return unpack(slots[i]) end end
  e.GetActionText = function() return "TestMacro" end
  return e, slots
end
test("bars restore spells, macros, items and empty slots; save replaces prior snapshot", function()
  local e, slots = barsEnvironment()
  slots[1], slots[2], slots[3] = {"spell", 123}, {"macro", 121}, {"item", 456}
  command("savebars", e)
  local b = e.Blizzard_Console_SavedVars.sb[62].Test
  assert(b[2][2] == "TestMacro" and b[3][2] == 456)
  slots[1], slots[2], slots[3], slots[4] = nil, nil, nil, {"spell", 789}
  command("loadbars", e)
  assert(slots[1][2] == 123 and slots[2][2] == "TestMacro" and slots[3][2] == 456)
  assert(slots[4] == nil and e.GetCursorInfo() == nil)
  slots[3] = nil
  command("savebars", e)
  assert(e.Blizzard_Console_SavedVars.sb[62].Test[3] == nil)
end)
test("bar preflight leaves existing slots intact for unsupported or unavailable actions", function()
  for _, action in ipairs({{"flyout", 1}, {"spell", 999}, {"macro", "missing"}}) do
    local e, slots = barsEnvironment()
    slots[1] = {"item", 42}
    e.Blizzard_Console_SavedVars.sb = {[62] = {Test = {[2] = action}}}
    command("loadbars", e)
    assert(slots[1][2] == 42 and slots[2] == nil and e.GetCursorInfo() == nil)
    assert(#e.messages > 0)
  end
  local e, slots = barsEnvironment()
  slots[1] = {"item", 42}
  e.Blizzard_Console_SavedVars.sb = {[62] = {Test = {}}}
  e.InCombatLockdown = function() return true end
  command("loadbars", e)
  assert(slots[1][2] == 42)
  e.InCombatLockdown = function() return false end
  e.C_ClassTalents.GetLastSelectedSavedConfigID = function() end
  command("savebars", e)
  command("loadbars", e)
  assert(slots[1][2] == 42 and next(e.Blizzard_Console_SavedVars.sb[62].Test) == nil)
end)

test("way validates arguments and map before setting normalized coordinates", function()
  local e, point, map, allowed = environment(), nil, 1, true
  e.C_Map = {
    GetBestMapForUnit = function() return map end,
    CanSetUserWaypointOnMap = function() return allowed end,
    SetUserWaypoint = function(p) point = p end,
  }
  e.CreateVector2D = function(x, y) return {x = x, y = y} end
  e.UiMapPoint = {CreateFromVector2D = function(m, v) v.map = m; return v end}
  for _, msg in ipairs({"", "abc", "10", "1..2 3", "101 20", "-1 20", "10 20 garbage"}) do
    command("way", e, msg)
    assert(point == nil)
  end
  for _, msg in ipairs({"10 20", "10,20", " 10.0, 20.0 "}) do
    command("way", e, msg)
    assert(point.x == .1 and point.y == .2 and point.map == 1)
  end
  command("way", e, "0 100")
  assert(point.x == 0 and point.y == 1)
  point, map = nil, nil
  command("way", e, "10 20")
  assert(point == nil)
  map, allowed = 1, false
  command("way", e, "10 20")
  assert(point == nil)
end)
test("macroicon validates names, supports names with spaces and numeric icon IDs", function()
  local e, edited = environment(), nil
  e.GetMacroInfo = function(n) if n == "Test Macro" then return n, 1, "body" end end
  e.EditMacro = function(n, _, i) edited = {n, i} end
  for _, msg in ipairs({"", "Test", "Missing 123", "Test Macro 0", "Test Macro -1"}) do
    command("macroicon", e, msg)
    assert(edited == nil)
  end
  command("macroicon", e, " Test Macro 134400 ")
  assert(edited[1] == "Test Macro" and edited[2] == 134400)
  command("macroicon", e, "Test Macro INV_Misc_QuestionMark")
  assert(edited[2] == "INV_Misc_QuestionMark")
end)
local count = 0
for _ in pairs(commands) do count = count + 1 end
print(string.format("Validated %d macros, %d commands, %d regression groups. Largest: %d/255 bytes (%s).",
  #manifest, count, tests, largest, largestPath))
