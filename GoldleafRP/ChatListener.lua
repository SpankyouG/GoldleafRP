-- ChatListener.lua
-- Lightweight chat listener

GoldleafRP = GoldleafRP or {}
local GA = GoldleafRP

local function OnChatMsg(self, event, msg, sender, ...)
    if not GA.activeCharacter then return end

    local playerName = UnitName("player")
    if not playerName then return end
    playerName = playerName:gsub("%-.+", "")

    local lowerMsg = msg:lower()
    local lowerPlayer = playerName:lower()

    local triggered = false

    if event == "CHAT_MSG_WHISPER" then
        triggered = true
    end

    if lowerMsg:find(lowerPlayer, 1, true) then
        triggered = true
    end

    for nick, _ in pairs(GA.Nicknames or {}) do
        if lowerMsg:find(nick, 1, true) then
            triggered = true
            break
        end
    end

    if triggered then
        GA.lastTriggerMsg = msg

        C_Timer.After(0.2 + math.random() * 0.3, function()
            GA:ShowReplyBox(GA.lastTriggerMsg)
        end)
    end
end

function GA:InitChatListener()
    local f = CreateFrame("Frame")
    f:RegisterEvent("CHAT_MSG_SAY")
    f:RegisterEvent("CHAT_MSG_YELL")
    f:RegisterEvent("CHAT_MSG_PARTY")
    f:RegisterEvent("CHAT_MSG_PARTY_LEADER")
    f:RegisterEvent("CHAT_MSG_RAID")
    f:RegisterEvent("CHAT_MSG_RAID_LEADER")
    f:RegisterEvent("CHAT_MSG_GUILD")
    f:RegisterEvent("CHAT_MSG_OFFICER")
    f:RegisterEvent("CHAT_MSG_WHISPER")
    f:RegisterEvent("CHAT_MSG_CHANNEL")
    f:SetScript("OnEvent", OnChatMsg)
end