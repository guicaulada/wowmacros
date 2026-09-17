function gsubrun(b) return (("\n"..b):gsub("\n#run ([^\r\n]+)",function(a) return "\n"..a:gsub("%S+",function(k) return assert(GetMacroBody(k),"Missing macro: "..k) end) end)) end
