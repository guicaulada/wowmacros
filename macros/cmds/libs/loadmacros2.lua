for i=138,121,-1 do DeleteMacro(i) end for _,i in ipairs(k) do local m=l[i] if not CreateMacro(m[1],m[2],m[3],true) then return print("Macro restore failed: "..m[1]) end end
