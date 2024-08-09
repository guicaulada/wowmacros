function gsubrun(b) return gsub(b, "#run (.+)", function(a) return gsub(a, "%S+", function(k) return GetMacroBody(k) end) end) end
