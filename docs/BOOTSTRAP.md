# One-time installation (no addon)

If replacing an older naming scheme, run its existing uninstall/reset macro before `/reload`
and reinstalling. The new `~1.uninstall` only removes the new reserved prefixes.

1. Paste this entire line into WoW chat and press Enter to open the paste box.
   No macro needs to be created first:

<!-- BEGIN GENERATED: bootstrap-chat -->
```text
/run local e=CreateFrame("EditBox",nil,UIParent,"InputBoxTemplate") e:SetSize(600,300)e:SetPoint("CENTER")e:SetMultiLine(true)e:SetMaxLetters(0)e:SetScript("OnEnterPressed",function(s)assert(loadstring(s:GetText()))()s:Hide()end)e:SetFocus()
```
<!-- END GENERATED: bootstrap-chat -->

2. Copy **all** of [install.lua](../generated/install.lua), paste it into the box, and press Enter.
   This step executes the generated Lua installer from this repository.
3. The importer window opens with the full bundle already filled in. Click **Import**.
4. Click `~1.cmds` to register `/importmacros` and the other commands.

For later updates, run `/importmacros`, paste all of [macros.txt](../generated/macros.txt), and
click **Import**, then click `~1.cmds`. If importer code itself changed, `/reload`
and click `~1.cmds` to use the new importer implementation.

The bootstrap is only for this repository's generated installer; do not paste
arbitrary Lua into it. Normal update bundles are parsed as data and are not executed.
For a fresh reset, click `~1.uninstall` outside combat, or paste this line into chat:

<!-- BEGIN GENERATED: uninstall-chat -->
```text
/run if InCombatLockdown()then return print("Leave combat first.")end local count=0 for i=GetNumMacros(),1,-1 do local name=GetMacroInfo(i)if name and name:match("^~[123]%.")then DeleteMacro(i)count=count+1 end end print("Uninstalled",count,"macros.")
```
<!-- END GENERATED: uninstall-chat -->

It deletes **all general
macros whose names start with `~1.`, `~2.`, or `~3.`**, including itself.
It preserves other general macros (including `fly` and `run`) and all character
macros. Run `/reload` to discard old registered commands, then start at step 1.
No existing bootstrap or helper macro is required. This is a fresh installation,
not a name migration; remove old `fly` and `run` manually and use `/mount` instead.
Optional clickable shortcuts can be created manually; use names without a system
prefix so `~1.uninstall` preserves them.

For a retry, run the chat line again and paste the latest `install.lua` into the
box. The installer replaces the old window and callbacks.
Old `WOWMACROS1` and `WOWMACROS2` bundles
are no longer accepted.

The `WOWMACROS3` format encodes names, icons, and bodies as hexadecimal, separated
by a colon. It has no raw pipe characters or tabs for the text box to reinterpret.
The chat bootstrap line and every stored macro fit within 255 bytes.
When adding/removing sources or reducing chunk counts, reset and reinstall: chunk
IDs can change and the importer leaves obsolete macros in place.
