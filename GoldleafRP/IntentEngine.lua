-- IntentEngine.lua
-- Lightweight keyword/phrase → category filtering. No AI.

GoldleafRP = GoldleafRP or {}
local GA = GoldleafRP

--[[
    IntentMap
    key   = lowercase keyword or phrase
    value = list of category names (must match Goldleaf_Dialogue)

    Expand this table whenever you notice a common question.
]]
GA.IntentMap = {
    -- Greeting / introduction / name
    ["hi"]            = {"Greeting"},
    ["hello"]         = {"Greeting"},
    ["hey"]           = {"Greeting"},
    ["good morning"]  = {"Greeting"},
    ["good evening"]  = {"Greeting"},
    ["name"]          = {"Greeting", "About", "Origin"},
    ["who are you"]   = {"Greeting", "About", "Origin"},
    ["who r you"]     = {"Greeting", "About", "Origin"},
    ["introduce"]     = {"Greeting", "About", "Origin"},
    ["call you"]      = {"Greeting", "About", "Origin"},

    -- Origin / home
    ["where"]         = {"Origin", "About"},
    ["from"]          = {"Origin"},
    ["home"]          = {"Origin"},
    ["homeland"]      = {"Origin"},
    ["live"]          = {"Origin"},
    ["grew up"]       = {"Origin", "About"},
    ["born"]          = {"Origin"},

    -- Thanks
    ["thank"]         = {"Thanks"},
    ["thanks"]        = {"Thanks"},
    ["thx"]           = {"Thanks"},
    ["appreciate"]    = {"Thanks"},
    ["grateful"]      = {"Thanks"},

     -- Requests / invitations → offer Yes & No as possible replies
    ["join"]          = {"Yes", "No"},
    ["come with"]     = {"Yes", "No"},
    ["come along"]    = {"Yes", "No"},
    ["help us"]       = {"Yes", "No"},
    ["help me"]       = {"Yes", "No"},
    ["want to"]       = {"Yes", "No"},
    ["wanna"]         = {"Yes", "No"},
    ["will you"]      = {"Yes", "No"},
    ["would you"]     = {"Yes", "No"},
    ["can you"]       = {"Yes", "No"},
    ["could you"]     = {"Yes", "No"},
    ["group"]         = {"Yes", "No"},
    ["party"]         = {"Yes", "No"},
    ["invite"]        = {"Yes", "No"},
    ["follow me"]     = {"Yes", "No"},
    ["with us"]       = {"Yes", "No"},
    ["with me"]       = {"Yes", "No"},
    ["quest"]         = {"Yes", "No"},
    ["dungeon"]       = {"Yes", "No"},
    ["heal"]          = {"Yes", "No"},
    ["tank"]          = {"Yes", "No"},
    ["instance"]      = {"Yes", "No"},
    ["run"]           = {"Yes", "No"},

    -- Farewell
    ["bye"]           = {"Farewell"},
    ["goodbye"]       = {"Farewell"},
    ["farewell"]      = {"Farewell"},
    ["see you"]       = {"Farewell"},
    ["see ya"]        = {"Farewell"},
    ["later"]         = {"Farewell"},
    ["take care"]     = {"Farewell"},

    -- Conflict / calm
    ["fight"]         = {"Calm"},
    ["angry"]         = {"Calm"},
    ["mad"]           = {"Calm"},
    ["upset"]         = {"Calm"},
    ["problem"]       = {"Calm"},
    ["wrong"]         = {"Calm"},
    ["stop"]          = {"Calm"},
    ["chill"]         = {"Calm"},
    ["calm"]          = {"Calm"},
    ["drama"]         = {"Calm"},

    -- Humor
    ["joke"]          = {"Humor", "Wildcard"},
    ["funny"]         = {"Humor"},
    ["laugh"]         = {"Humor"},
    ["hilarious"]     = {"Humor"},
    ["kidding"]       = {"Humor"},

    -- Family / Goldleaf
    ["goldleaf"]      = {"Family", "About"},
    ["family"]        = {"Family", "About"},
    ["brother"]       = {"Family"},
    ["sister"]        = {"Family"},
    ["relative"]      = {"Family"},
    ["related"]       = {"Family"},

    -- Soft flavor triggers
    ["look"]          = {"Flavor"},
    ["feel"]          = {"Flavor"},
    ["hear"]          = {"Flavor"},
    ["smell"]         = {"Flavor"},
    ["weather"]       = {"Flavor"},
    ["light"]         = {"Flavor"},
    ["druid"]         = {"About", "Flavor"},
    ["nature"]        = {"Flavor", "About"},
    ["bear"]          = {"Flavor"},
    ["wild"]          = {"Flavor"},
    ["forest"]        = {"Origin", "Flavor"},
}

-- Simple word-boundary check (avoids "no" matching "know")
local function containsWord(text, word)
    return text:find("%f[%w]" .. word .. "%f[%W]")
        or text:find("^" .. word .. "%f[%W]")
        or text:find("%f[%w]" .. word .. "$")
end

--[[
    Returns a sorted list of relevant categories, or nil (= show all).
]]
function GA:GetRelevantCategories(msg)
    if not msg or msg == "" then return nil end
    if not self.activeTables or not self.activeTables.Replies then return nil end

    local lower = msg:lower()
    local scores = {}

    for keyword, categories in pairs(self.IntentMap) do
        local matched
        if keyword:find(" ", 1, true) then
            matched = lower:find(keyword, 1, true)
        else
            matched = containsWord(lower, keyword)
        end

        if matched then
            for _, cat in ipairs(categories) do
                if self.activeTables.Replies[cat] then
                    scores[cat] = (scores[cat] or 0) + 1
                end
            end
        end
    end

    local list = {}
    for cat, score in pairs(scores) do
        if score > 0 then
            table.insert(list, cat)
        end
    end

    if #list == 0 then
        return nil
    end

    table.sort(list)
    return list
end