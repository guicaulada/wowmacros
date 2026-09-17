-- Reuse the window until /reload or a fresh bootstrap replaces its callbacks.
local window = WoWMacrosImport
if window then
    window:Show()
    window.Input:SetFocus()
    return
end

window = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
WoWMacrosImport = window
window:SetSize(620, 440)
window:SetPoint("CENTER")
window:SetFrameStrata("DIALOG")
window.TitleText:SetText("Import account macros")
window:SetMovable(true)
window:EnableMouse(true)
window:RegisterForDrag("LeftButton")
window:SetScript("OnDragStart", window.StartMoving)
window:SetScript("OnDragStop", window.StopMovingOrSizing)

local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 16, -40)
scroll:SetPoint("BOTTOMRIGHT", -34, 60)

-- A multiline EditBox accepts a complete pasted bundle on GeForce Now.
local input = CreateFrame("EditBox", nil, scroll)
window.Input = input
input:SetWidth(560)
input:SetHeight(320)
input:SetMultiLine(true)
input:SetFontObject(ChatFontNormal)
input:SetAutoFocus(false)
input:SetMaxLetters(0)
scroll:SetScrollChild(input)
input:SetScript("OnEscapePressed", function()
    input:ClearFocus()
    window:Hide()
end)
input:SetScript("OnCursorChanged", function(_, x, y, width, height)
    -- EditBox cursor coordinates grow downward as negative y values.
    local cursor = -y
    local offset = scroll:GetVerticalScroll()
    if cursor < offset then
        scroll:SetVerticalScroll(cursor)
    elseif cursor + height > offset + scroll:GetHeight() then
        scroll:SetVerticalScroll(cursor + height - scroll:GetHeight())
    end
end)

local button = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
button:SetSize(100, 24)
button:SetPoint("BOTTOMRIGHT", -16, 16)
button:SetText("Import")
local hint = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
hint:SetPoint("BOTTOMLEFT", 16, 20)
hint:SetText("Paste a WOWMACROS3 bundle, then click Import.")

button:SetScript("OnClick", function()
    local function fail(message)
        print("Import: " .. message)
    end
    if InCombatLockdown() then return fail("leave combat first.") end

    -- Normal imports decode data only; they never execute the pasted text.
    local raw = input:GetText():gsub("\r\n", "\n")
    local count, body = raw:match("^WOWMACROS3 (%d+)\n(.*)\nEND%s*$")
    if not count then return fail("expected a complete WOWMACROS3 bundle.") end
    local capacity = Constants and Constants.MacroConsts and Constants.MacroConsts.MAX_ACCOUNT_MACROS or 120
    local rows, seen = {}, {}
    local function bad(message)
        return fail("entry " .. (#rows + 1) .. ": " .. message)
    end
    local function decode(hex)
        return (hex:gsub("..", function(pair)
            return string.char(tonumber(pair, 16))
        end))
    end

    -- Validate every row before creating or updating even one macro.
    for line in (body .. "\n"):gmatch("(.-)\n") do
        local nameHex, iconHex, bodyHex = line:match("^(%x+):(%x*):(%x*)$")
        if not nameHex then return bad("expected hex name:icon:body; paste the latest bundle.") end
        if #nameHex % 2 ~= 0 or #iconHex % 2 ~= 0 or #bodyHex % 2 ~= 0 then
            return bad("incomplete hex data.")
        end
        if #nameHex > 32 then return bad("name exceeds 16 bytes.") end
        if #bodyHex > 510 then return bad("body exceeds 255 bytes.") end

        local name, content = decode(nameHex), decode(bodyHex)
        if name:find("%c") then return bad("control byte in name.") end
        if seen[name] then return bad("duplicate name.") end
        if content:find("%z") then return bad("NUL byte in macro.") end
        local icon
        if iconHex ~= "" then
            local path = decode(iconHex)
            if #path > 128 or not path:match("^[%w_]+$") then return bad("invalid icon name.") end
            icon = GetFileIDFromPath("Interface/Icons/" .. path)
            if not icon or icon <= 0 then return bad("icon not found: " .. path) end
        end
        rows[#rows + 1] = {name, content, icon}
        seen[name] = true
    end
    if #rows ~= tonumber(count) or #rows == 0 or #rows > capacity then
        return fail("invalid entry count.")
    end

    -- Macro indices can change when WoW sorts after a write. Resolve the exact
    -- account name each time; character macros are outside this index range.
    -- nil means missing, false means an ambiguous duplicate, a number is its index.
    local function find(name)
        local found
        for index = 1, GetNumMacros() do
            if GetMacroInfo(index) == name then
                if found then return false end
                found = index
            end
        end
        return found
    end
    local needed = 0
    for _, row in ipairs(rows) do
        local index = find(row[1])
        if index == false then return fail("ambiguous account macro: " .. row[1]) end
        if not index then needed = needed + 1 end
    end
    if GetNumMacros() + needed > capacity then return fail("not enough account macro slots.") end

    local created, updated, unchanged = 0, 0, 0
    for _, row in ipairs(rows) do
        local name, content, icon = row[1], row[2], row[3]
        local index = find(name)
        local old = index and {GetMacroInfo(index)} or {}
        if old[1] == name and old[3] == content and (not icon or old[2] == icon) then
            unchanged = unchanged + 1
        else
            -- Passing nil as the new name preserves exact names; no migrations.
            local ok, errorMessage
            if index then
                ok, errorMessage = pcall(EditMacro, index, nil, icon, content)
            else
                ok, errorMessage = pcall(CreateMacro, name, icon or 134400, content, false)
            end
            if not ok then
                return fail("stopped at " .. name .. ": " .. tostring(errorMessage) .. "; earlier changes remain.")
            end

            -- Some API failures do not throw. Read back the result before counting
            -- it as successful. Stop on failure; earlier writes are not rolled back.
            local written = find(name)
            if not written or GetMacroInfo(written) ~= name
                or select(3, GetMacroInfo(written)) ~= content
                or (icon and select(2, GetMacroInfo(written)) ~= icon) then
                return fail("could not write " .. name .. "; earlier changes remain.")
            end
            if index then updated = updated + 1 else created = created + 1 end
        end
    end
    print("Imported:", created, "created,", updated, "updated,", unchanged, "unchanged. Click ~1.cmds to register commands.")
    input:ClearFocus()
    window:Hide()
end)
window:Show()
input:SetFocus()
