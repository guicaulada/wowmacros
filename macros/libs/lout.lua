local C=C_ClassTalents local p=PlayerUtil.GetCurrentSpecID() local _LO={class=UnitClass("player"),spec=p,name=C_Traits.GetConfigInfo(C.GetLastSelectedSavedConfigID(p)).name,configs=C.GetConfigIDsBySpecID(p)}
