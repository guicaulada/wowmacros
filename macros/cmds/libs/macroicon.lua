if not n or n=="" or not GetMacroInfo(n) or (tonumber(i) and tonumber(i)<=0) then return print("Usage: /macroicon <existing macro name> <icon name or ID>") end EditMacro(n,nil,tonumber(i) or i)
