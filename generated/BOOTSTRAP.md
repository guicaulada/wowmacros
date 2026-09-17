# One-time installation (no addon)

1. Create a general/account macro named `{import}` and paste this entire line:

<!-- BEGIN GENERATED: bootstrap-macro -->
```text
/run local e=CreateFrame("EditBox",nil,UIParent,"InputBoxTemplate") e:SetSize(600,300)e:SetPoint("CENTER")e:SetMultiLine(true)e:SetMaxLetters(0)e:SetScript("OnEnterPressed",function(s)assert(loadstring(s:GetText()))()s:Hide()end)e:SetFocus()
```
<!-- END GENERATED: bootstrap-macro -->

2. Click `{import}` to open the paste box.
3. Copy **all** of [install.lua](install.lua), paste it into the box, and press Enter.
   This step executes the generated Lua installer from this repository.
4. The importer window opens with the full bundle already filled in. Click **Import**.
5. Click `{cmds}` to register `/importmacros` and the other commands.

For later updates, run `/importmacros`, paste all of [macros.txt](macros.txt), and
click **Import**, then click `{cmds}`. If importer code itself changed, `/reload`
and click `{cmds}` to use the new importer implementation.

The bootstrap is only for this repository's generated installer; do not paste
arbitrary Lua into it. Normal update bundles are parsed as data and are not executed.
For a fresh reset, first create and run `{clear}` using
[clear.lua](../macros/core/clear.lua), outside combat. It deletes **all general
macros whose names start with `{`, `[`, or `|`**, including itself and `{import}`.
It preserves other general macros (including `fly` and `run`) and all character
macros. Run `/reload` to discard old registered commands, then start at step 1.
No existing bootstrap or helper macro is required. This is a fresh installation,
not a name migration; handle existing `fly` and `run` casing manually.

For a retry, paste the latest `install.lua` into `{import}` again. The installer
replaces the old window and callbacks. Old `WOWMACROS1` and `WOWMACROS2` bundles
are no longer accepted.

The `WOWMACROS3` format encodes names, icons, and bodies as hexadecimal, separated
by a colon. It has no raw pipe characters or tabs for the text box to reinterpret.
All stored macros, including the bootstrap and importer helpers, fit within 255 bytes.
