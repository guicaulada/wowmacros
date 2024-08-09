#cmd clearquests
local L = C_QuestLog for i=1,L.GetNumQuestLogEntries() do local q = L.GetInfo(i) if q.campaignID == nil then L.SetSelectedQuest(q.questID) L.SetAbandonQuest() L.AbandonQuest() end end