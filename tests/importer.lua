-- Exercise the generated importer and the chat bootstrap using WoW mocks.
local function read(path)
  local f=assert(io.open(path,"rb")) local s=f:read("*a") f:close() return s
end
local manifest=dofile("generated/manifest.lua")
local bodies=dofile("tests/read-bundle.lua")
local storedBodies={}
for _,entry in ipairs(manifest) do
  storedBodies[entry[1]]=assert(bodies[entry[1]])
end
local function compile(code,env)
  return setfenv(assert(loadstring(code)),env)
end
local function hex(s) return (s:gsub(".",function(c) return string.format("%02x",c:byte()) end)) end
local function bundle(rows)
  local lines={"WOWMACROS3 "..#rows}
  for _,r in ipairs(rows) do lines[#lines+1]=hex(r[1])..":"..hex(r[3] or "")..":"..hex(r[2]) end
  lines[#lines+1]="END" return table.concat(lines,"\n").."\n"
end
local function environment(initial,capacity)
  local e=setmetatable({accounts=initial or {},frames={},messages={},writes=0}, {__index=_G})
  e._G=e e.UIParent={} e.ChatFontNormal={}
  e.Constants={MacroConsts={MAX_ACCOUNT_MACROS=capacity or 120}}
  e.InCombatLockdown=function() return e.combat end
  e.print=function(...) e.messages[#e.messages+1]={...} end
  e.GetFileIDFromPath=function(path)
    return ({["Interface/Icons/inv_misc_punchcards_red"]=101,
             ["Interface/Icons/inv_misc_punchcards_yellow"]=102,
             ["Interface/Icons/inv_misc_punchcards_blue"]=103,
             ["Interface/Icons/inv_misc_punchcards_white"]=104})[path] or 0
  end
  e.GetNumMacros=function() return #e.accounts,1 end
  e.GetMacroInfo=function(i)
    if i==121 then return "CharacterOnly",77,"untouched" end
    local m=e.accounts[i] if m then return unpack(m) end
  end
  local function sort() table.sort(e.accounts,function(a,b) return a[1]<b[1] end) end
  e.CreateMacro=function(n,icon,body,character)
    assert(character==false,"Must create account macros")
    assert(#e.accounts<e.Constants.MacroConsts.MAX_ACCOUNT_MACROS)
    assert(#n<=16 and #body<=255)
    e.accounts[#e.accounts+1]={n,icon,body} sort() e.writes=e.writes+1
    for i,m in ipairs(e.accounts) do if m[1]==n then return i end end
  end
  e.EditMacro=function(i,name,icon,body)
    assert(e.accounts[i] and name==nil,"Only edit exact matches; never rename")
    assert(#body<=255)
    e.accounts[i]={name or e.accounts[i][1],icon or e.accounts[i][2],body} sort() e.writes=e.writes+1 return i
  end
  e.GetMacroBody=function(n) return storedBodies[n] end
  e.loadstring=function(code) return compile(code,e) end
  e.gsub=string.gsub
  local methods={}
  function methods:SetText(text) self.text=text end
  function methods:GetText() return self.text or "" end
  function methods:SetScript(event,fn) self.scripts[event]=fn end
  function methods:SetSize(w,h) self.width,self.height=w,h end
  function methods:SetWidth(w) self.width=w end
  function methods:SetHeight(h) self.height=h end
  function methods:GetHeight() return self.height or 340 end
  function methods:SetScrollChild(child) self.child=child end
  function methods:SetVerticalScroll(v) self.scroll=v end
  function methods:GetVerticalScroll() return self.scroll or 0 end
  function methods:SetMaxLetters(n) self.maxLetters=n end
  function methods:SetMultiLine(v) self.multiline=v end
  function methods:Show() self.shown=true end
  function methods:Hide() self.shown=false end
  function methods:SetFocus() self.focus=true end
  function methods:ClearFocus() self.focus=false end
  for _,name in ipairs({"SetPoint","SetFrameStrata","SetMovable","EnableMouse","RegisterForDrag",
    "StartMoving","StopMovingOrSizing","SetFontObject","SetAutoFocus"}) do methods[name]=function() end end
  local function frame(kind,parent,template)
    local obj=setmetatable({kind=kind,parent=parent,template=template,scripts={}}, {__index=methods})
    if template=="BasicFrameTemplateWithInset" then obj.TitleText=frame("FontString",obj) end
    return obj
  end
  function methods:CreateFontString() return frame("FontString",self) end
  e.CreateFrame=function(kind,name,parent,template)
    local obj=frame(kind,parent,template) e.frames[#e.frames+1]=obj return obj
  end
  sort()
  return e
end
local function open(e)
  e.SlashCmdList={}
  compile(bodies["~1.cmds"]:sub(6),e)()
  e.SlashCmdList.WOWMACROS_importmacros("")
end
local function click(e,text)
  e.WoWMacrosImport.Input:SetText(text)
  for _,f in ipairs(e.frames) do
    if f.kind=="Button" and f.text=="Import" then return f.scripts.OnClick(f) end
  end
  error("No import button")
end
local function get(e,name)
  for _,m in ipairs(e.accounts) do if m[1]==name then return m end end
end
local count=0
local function test(name,fn)
  local ok,err=pcall(fn) assert(ok,name..": "..tostring(err))
  count=count+1 print("PASS "..name)
end

test("update by exact account name, preserve icons, create missing, skip unchanged, tolerate sorting",function()
  local e=environment({{"Z",42,"old"},{"Keep",88,"unchanged"}})
  open(e)
  local data=bundle({{"A","new"},{"Z","updated"},{"CharacterOnly","account version"}})
  click(e,data)
  assert(e.writes==3 and #e.accounts==4)
  assert(get(e,"Z")[2]==42 and get(e,"Z")[3]=="updated")
  assert(get(e,"A")[2]==134400 and get(e,"Keep")[3]=="unchanged")
  assert(select(3,e.GetMacroInfo(121))=="untouched")
  click(e,data)
  assert(e.writes==3 and #e.accounts==4)
  local n=#e.frames open(e)
  assert(#e.frames==n and e.WoWMacrosImport.shown)
end)

test("full generated bundle round-trips all macro bodies without executing them",function()
  local e=environment()
  open(e) click(e,read("generated/macros.txt"))
  assert(#e.accounts==#manifest and e.writes==#manifest)
  for name,body in pairs(bodies) do assert(get(e,name)[3]==body,name) end
  click(e,read("generated/macros.txt"))
  assert(e.writes==#manifest)
  click(e,bundle({{"DataOnly","_G.executed=true\n#run missing\n"}}))
  assert(e.executed==nil and get(e,"DataOnly"))
end)

test("chat bootstrap starts with no macros; only clicking Import writes",function()
  local e=environment()
  -- There are no installed chunks yet. Read only what the importer creates.
  e.GetMacroBody=function(name) local macro=get(e,name) return macro and macro[3] end
  compile(read("generated/bootstrap.lua"):sub(6),e)()
  local bootstrap=e.frames[1]
  assert(bootstrap.multiline and bootstrap.maxLetters==0)
  bootstrap:SetText(read("generated/install.lua"))
  bootstrap.scripts.OnEnterPressed(bootstrap)
  assert(e.writes==0 and #e.accounts==0 and bootstrap.shown==false)
  assert(e.WoWMacrosImport.Input:GetText()==read("generated/macros.txt"))
  click(e,e.WoWMacrosImport.Input:GetText())
  assert(e.writes==#manifest)
  e.SlashCmdList={}
  compile(get(e,"~1.cmds")[3]:sub(6),e)()
  assert(e.SlashCmdList.WOWMACROS_fly==nil)
  assert(type(e.SlashCmdList.WOWMACROS_mount)=="function")
end)

test("paste transport avoids pipe escapes and tab conversion",function()
  local function transport(s) return (s:gsub("||","|"):gsub("\t","    ")) end
  local data=read("generated/macros.txt")
  assert(not data:find("|",1,true) and not data:find("\t",1,true))
  assert(transport(data)==data)
  local installer=read("generated/install.lua")
  assert(transport(installer)==installer)
  local function escape(s) return (s:gsub("|","||"):gsub("\t","    ")) end
  assert(escape(data)==data and escape(installer)==installer)
  local e=environment() open(e) click(e,transport(data))
  for name,body in pairs(bodies) do assert(get(e,name)[3]==body,name) end
end)

test("rerunning bootstrap replaces the cached importer instead of reusing stale callbacks",function()
  local e=environment() open(e)
  local old=e.WoWMacrosImport
  compile(read("generated/install.lua"),e)()
  assert(old.shown==false and e.WoWMacrosImport~=old)
  assert(e.WoWMacrosImport.Input:GetText()==read("generated/macros.txt"))
  -- Find the new button, since old hidden UI objects also remain allocated.
  for _,f in ipairs(e.frames) do
    if f.kind=="Button" and f.parent==e.WoWMacrosImport then f.scripts.OnClick(f) end
  end
  assert(e.writes==#manifest)
end)

test("entry diagnostics identify the row and reason without changing macros",function()
  local e=environment() open(e)
  click(e,"WOWMACROS3 2\n41::41\n42::4\nEND\n")
  assert(e.writes==0 and e.messages[#e.messages][1]:find("entry 2: incomplete hex data",1,true))
  click(e,bundle({{"A","a"},{"A","b"}}))
  assert(e.writes==0 and e.messages[#e.messages][1]:find("entry 2: duplicate name",1,true))
end)

test("invalid bundles and ambiguous names fail before any writes",function()
  local invalid={
    "", "return os.execute('bad')", "WOWMACROS3 1\n41::2\nEND\n",
    "WOWMACROS3 1\n41::zz\nEND\n", "WOWMACROS3 2\n41::41\nEND\n",
    "WOWMACROS3 1\n41::41\n", "WOWMACROS3 1\n41::41\nEND\nextra",
    bundle({{"A","valid"},{"A","duplicate"}}), bundle({{"A",string.rep("x",256)}}),
    bundle({{string.rep("n",17),"body"}}), bundle({{"A","nul\0byte"}}),
    "WOWMACROS3 0\n\nEND\n", "WOWMACROS1 1\nA\t41\nEND\n", "WOWMACROS2 1\n41:41\nEND\n",
    "WOWMACROS3 1\n4::41\nEND\n",
  }
  for _,data in ipairs(invalid) do
    local e=environment({{"A",8,"old"}}) open(e) click(e,data)
    assert(e.writes==0 and get(e,"A")[3]=="old" and #e.messages>0,data)
  end
  local e=environment({{"A",8,"old"},{"A",9,"other"}})
  open(e) click(e,bundle({{"A","new"}})) assert(e.writes==0)
end)

test("capacity and combat checks precede changes, but updates work when full",function()
  local e=environment({{"A",8,"old"}},1)
  open(e) click(e,bundle({{"A","new"},{"B","new"}}))
  assert(e.writes==0 and get(e,"A")[3]=="old")
  e.combat=true click(e,bundle({{"A","new"}})) assert(e.writes==0)
  e.combat=false click(e,bundle({{"A","new"}})) assert(e.writes==1)
end)

test("CRLF, Unicode and an exact 255-byte body survive data decoding",function()
  local e=environment() open(e)
  local data=bundle({{"Boundary",string.rep("x",255)},{"Unicode","/run print('Olá')\n"}}):gsub("\n","\r\n")
  click(e,data)
  assert(#get(e,"Boundary")[3]==255 and get(e,"Unicode")[3]=="/run print('Olá')\n")
end)

test("category icons are applied on creation and icon-only updates, then skipped",function()
  local e=environment({{"~1.cmds",42,bodies["~1.cmds"]},{"fly",88,"/fly"}})
  open(e) click(e,read("generated/macros.txt"))
  for _,entry in ipairs(manifest) do
    local name=entry[1] local icon=get(e,name)[2]
    assert(icon==({core=101,libs=104,chunks=102})[entry[3]],name)
  end
  assert(get(e,"fly")[2]==88)
  local writes=e.writes click(e,read("generated/macros.txt")) assert(e.writes==writes)
end)

test("standalone uninstall removes all prefixed account macros, including itself, and permits fresh bootstrap",function()
  local e=environment({{"~1.uninstall",1,bodies["~1.uninstall"]},{"~1.cmds",1,"old"},
    {"~1.example",1,"old"},{"~2.load",1,"old"},{"~2.save",1,"old"},{"~3.c001.001",1,"old"},{"~3.k001.001",1,"old"},
    {"~3.l001.002",1,"old"},{"fly",88,"/fly"},{"run",89,"/mount"},{"Other",42,"keep"}})
  local info=e.GetMacroInfo
  e.GetMacroInfo=function(i) if i==121 then return "{Character}",77,"keep" end return info(i) end
  local deleted=0
  e.DeleteMacro=function(i)
    assert(i>=1 and i<=#e.accounts,"Must only delete account macros")
    table.remove(e.accounts,i) deleted=deleted+1
  end
  local uninstall=compile(bodies["~1.uninstall"]:sub(6),e)
  e.combat=true uninstall() assert(deleted==0 and #e.accounts==11)
  e.combat=false uninstall()
  assert(deleted==8 and #e.accounts==3 and not get(e,"~1.uninstall"))
  assert(get(e,"fly")[2]==88 and get(e,"run")[2]==89 and get(e,"Other")[3]=="keep")
  assert(e.GetMacroInfo(121)=="{Character}")
  uninstall() assert(deleted==8) -- Empty prefix set is harmless.
  -- Execute the chat /run payload after uninstalling, without creating a seed macro.
  compile(read("generated/bootstrap.lua"):sub(6),e)()
  local bootstrap=e.frames[1]
  bootstrap:SetText(read("generated/install.lua"))
  bootstrap.scripts.OnEnterPressed(bootstrap)
  click(e,e.WoWMacrosImport.Input:GetText())
  for name,body in pairs(bodies) do assert(get(e,name)[3]==body,name) end
  assert(#e.accounts==#manifest+3 and get(e,"Other")[3]=="keep")
  assert(get(e,"~1.uninstall")[2]==101 and not get(e,"~1.import"))
end)

test("pipe-free stored names are identical to display names",function()
  local e=environment() open(e) click(e,read("generated/macros.txt"))
  for _,entry in ipairs(manifest) do
    local name=entry[1] local macro=get(e,name)
    assert(macro[1]==name and #name<=16,name)
    assert(not name:find("|",1,true),name)
  end
  assert(get(e,"~3.c001.001"))
  assert(get(e,"~2.load"))
  assert(not get(e,"[accountbars]"))
  assert(not get(e,"[way]"))
end)

test("imports use exact names without casing or legacy-name migrations",function()
  local e=environment({{"FLY",88,"old"},{"{|save|}",42,"old"}})
  open(e) click(e,bundle({{"fly","/fly"},{"~2.save",bodies["~2.save"],"inv_misc_punchcards_white"}}))
  assert(#e.accounts==4 and get(e,"FLY")[3]=="old")
  assert(get(e,"{|save|}")[3]=="old" and get(e,"~2.save"))
  local writes=e.writes click(e,bundle({{"fly","/fly"}})) assert(e.writes==writes)
end)

test("invalid or unknown icons abort before edits",function()
  for _,icon in ipairs({"missing_icon","../bad","bad\nicon"}) do
    local e=environment({{"A",88,"old"}}) open(e)
    click(e,bundle({{"A","new"},{"B","new",icon}}))
    assert(e.writes==0 and get(e,"A")[3]=="old")
  end
end)

test("API failures stop and report earlier changes without claiming success",function()
  for _,silent in ipairs({false,true}) do
    local e=environment() local create=e.CreateMacro
    e.CreateMacro=function(n,...)
      if n=="B" then if silent then return nil else error("blocked") end end
      return create(n,...)
    end
    open(e) click(e,bundle({{"A","a"},{"B","b"},{"C","c"}}))
    assert(e.writes==1 and get(e,"A") and not get(e,"B") and not get(e,"C"))
    assert(e.messages[#e.messages][1]:find("earlier changes remain",1,true))
    assert(e.WoWMacrosImport.shown)
  end
end)
print("Validated "..count.." importer regression groups.")
