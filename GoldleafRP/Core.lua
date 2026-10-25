-- GoldleafRP Core
GoldleafRP = GoldleafRP or {}
local GA = GoldleafRP

GA.version = "1.0.1"
GA.activeCharacter = nil
GA.activeTables = nil
GA.shuffleBags = {}

GoldleafRPDB = GoldleafRPDB or {
    lastStarter = {},
    bagState = {},
}

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff7CFC00[Goldleaf]|r " .. tostring(msg))
end

local function Shuffle(t)
    local n = #t
    for i = n, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function GA:GetNextLine(category)
    if not self.activeTables or not self.activeTables.Replies or not self.activeTables.Replies[category] then
        return "…"
    end

    local bagKey = (self.activeCharacter or "None") .. "_" .. category
    local bag = self.shuffleBags[bagKey]

    if not bag or #bag == 0 then
        bag = {}
        for _, line in ipairs(self.activeTables.Replies[category]) do
            table.insert(bag, line)
        end
        Shuffle(bag)
        self.shuffleBags[bagKey] = bag
    end

    return table.remove(bag, 1)
end

function GA:GetNextStarter()
    if not self.activeTables or not self.activeTables.RPStarters then
        return "The forest is quiet…"
    end

    local bagKey = (self.activeCharacter or "None") .. "_RPStarter"
    local bag = self.shuffleBags[bagKey]

    if not bag or #bag == 0 then
        bag = {}
        for _, line in ipairs(self.activeTables.RPStarters) do
            table.insert(bag, line)
        end
        Shuffle(bag)
        self.shuffleBags[bagKey] = bag
    end

    return table.remove(bag, 1)
end

-- Single authoritative SetActiveCharacter
function GA:SetActiveCharacter(name)
    self.activeCharacter = name
    self.activeTables = Goldleaf_Dialogue and Goldleaf_Dialogue[name]
    self.shuffleBags = {}          -- always start fresh

    if self.activeTables then
        Print("Active Goldleaf: " .. name)
    else
        Print("|cffff0000ERROR: No dialogue table found for " .. tostring(name) .. "|r")
    end
end

-- Slash commands
SLASH_GOLDLEAF1 = "/goldleaf"
SlashCmdList["GOLDLEAF"] = function(msg)
    msg = strtrim(msg or ""):lower()
    if msg == "reload" or msg == "r" then
        ReloadUI()
    elseif msg == "status" then
        Print("Active: " .. tostring(GA.activeCharacter or "none"))
    else
        Print("GoldleafRP v" .. GA.version)
        Print("/goldleaf status  – show active character")
        Print("/goldleaf reload  – reload UI")
    end
end

-- Single initialization point
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "GoldleafRP" then
        -- tables are already loaded from Goldleaf_Dialogue.lua
    elseif event == "PLAYER_LOGIN" then
        if GA.DetectCharacter then
            GA:DetectCharacter()
        end
        if GA.InitChatListener then
            GA:InitChatListener()
        end
        if GA.CreateStarterButton then
            GA:CreateStarterButton()
        end
        Print("GoldleafRP loaded. Playing as: " .. tostring(GA.activeCharacter or "none"))
    end
end)