/run local t=assert(loadstring(assert(GetMacroBody("{[mount]}"),"Missing {[mount]}")))()({[230]=true},true) if #t>0 then C_MountJournal.SummonByID(t[random(#t)]) else print("No matching mount.") end
