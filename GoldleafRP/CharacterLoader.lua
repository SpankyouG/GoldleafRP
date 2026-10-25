-- Character detection
GoldleafRP = GoldleafRP or {}
local GA = GoldleafRP

local KNOWN = {
    ["Spankor"]   = true,
    ["Pure"]    = true,
    ["Gorlock"] = true,
    ["Puffin"]  = true,
    ["Orion"]   = true,
    ["Karena"]  = true,
    ["Sticky"]  = true,
    ["Zongo"]   = true,
    ["Ares"]    = true,
}

GA.Nicknames = {
    ["spank"] = "Spankor",
    ["gor"]   = "Gorlock",
    ["karen"] = "Karena",
    ["puff"]  = "Puffin",
}

function GA:DetectCharacter()
    local playerName = UnitName("player")
    if not playerName then return end

    -- Strip realm name
    playerName = playerName:gsub("%-.+", "")

    if KNOWN[playerName] then
        GA:SetActiveCharacter(playerName)
        return
    end

    local lower = playerName:lower()
    if GA.Nicknames[lower] then
        GA:SetActiveCharacter(GA.Nicknames[lower])
        return
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff7CFC00[Goldleaf]|r No matching Goldleaf character detected for '" .. playerName .. "'. Dialogue disabled.")
end