#cmd clearloadouts
local C = C_ClassTalents for _,v in pairs(C.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())) do C.DeleteConfig(v) end C.SetStarterBuildActive(true)
