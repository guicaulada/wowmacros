local old=i and {GetMacroInfo(i)} or {}
if old[1]==n and old[3]==v and (not icon or old[2]==icon) then same=same+1 else
local ok,err
if i then ok,err=pcall(EditMacro,i,nil,icon,v) else ok,err=pcall(CreateMacro,n,icon or 134400,v,false) end
