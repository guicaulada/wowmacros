-- Preserve campaign quests while abandoning other entries in the quest log.
local log = C_QuestLog
for i = 1, log.GetNumQuestLogEntries() do
    local quest = log.GetInfo(i)
    if quest.campaignID == nil then
        log.SetSelectedQuest(quest.questID)
        log.SetAbandonQuest()
        log.AbandonQuest()
    end
end
