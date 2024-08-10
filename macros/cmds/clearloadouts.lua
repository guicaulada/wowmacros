#cmd clearloadouts
#run {|LOUT|}
for _,v in pairs(_LO.configs) do C.DeleteConfig(v) end C.SetStarterBuildActive(true)
