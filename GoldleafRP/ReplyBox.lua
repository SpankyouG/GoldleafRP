-- ReplyBox.lua
-- GoldleafRP Dynamic Reply Browser

GoldleafRP = GoldleafRP or {}
local GA = GoldleafRP

local frame
local buttons = {}

local function ClearButtons()
    for _, btn in ipairs(buttons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    buttons = {}
end

local function CreateReplyFrame()
    if frame then return frame end

    frame = CreateFrame("Frame", "GoldleafReplyBox", UIParent, "BackdropTemplate")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:Hide()

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {
            left = 8,
            right = 8,
            top = 8,
            bottom = 8
        }
    })

    frame:SetBackdropColor(0, 0, 0, 0.9)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -14)
    title:SetText("|cff7CFC00Goldleaf Reply|r")
    frame.title = title

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function()
        frame:Hide()
    end)

    frame:EnableKeyboard(true)
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
        end
    end)

    return frame
end

------------------------------------------------------------
-- SHOW INDIVIDUAL LINES FOR A CATEGORY
------------------------------------------------------------

function GA:ShowCategoryLines(category, triggerMsg)

    if not self.activeTables
        or not self.activeTables.Replies
        or not self.activeTables.Replies[category]
    then
        return
    end

    local f = CreateReplyFrame()

    ClearButtons()

    local lines = self.activeTables.Replies[category]

    local count = #lines + 1 -- Back button
    local height = math.min(600, 60 + (count * 28))

    f:SetSize(420, height)

    f.title:SetText("|cff7CFC00" .. category .. "|r")

    --------------------------------------------------------
    -- BACK BUTTON
    --------------------------------------------------------

    local back = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    back:SetSize(360, 24)
    back:SetPoint("TOP", 0, -30)
    back:SetText("<< Back")

    back:SetScript("OnClick", function()
        GA:ShowReplyBox(triggerMsg)
    end)

    table.insert(buttons, back)

    --------------------------------------------------------
    -- RESPONSE LINES
    --------------------------------------------------------

    for i, line in ipairs(lines) do

        local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")

        btn:SetSize(360, 24)
        btn:SetPoint("TOP", 0, -30 - (i * 28))

        local short = line

        if short:len() > 55 then
            short = short:sub(1, 55) .. "..."
        end

        btn:SetText(short)

        btn:SetScript("OnClick", function()

            local editBox = ChatEdit_ChooseBoxForSend() or ChatFrame1EditBox

            if editBox then
                ChatEdit_ActivateChat(editBox)
                editBox:SetText(line)
            end

            f:Hide()
        end)

        table.insert(buttons, btn)
    end
end

------------------------------------------------------------
-- MAIN CATEGORY SCREEN
------------------------------------------------------------

function GA:ShowReplyBox(triggerMsg)

    if not self.activeCharacter or not self.activeTables then
        return
    end

    if not self.activeTables.Replies then
        return
    end

    local f = CreateReplyFrame()

    ClearButtons()

    f.title:SetText("|cff7CFC00Goldleaf Reply|r")

    --------------------------------------------------------
    -- DECIDE WHICH CATEGORIES TO SHOW
    --------------------------------------------------------

    local categories = nil

    if triggerMsg and GA.GetRelevantCategories then
        categories = GA:GetRelevantCategories(triggerMsg)
    end

    if not categories then
        categories = {}

        for catName, _ in pairs(self.activeTables.Replies) do
            table.insert(categories, catName)
        end

        table.sort(categories)
    end

    --------------------------------------------------------
    -- RESIZE
    --------------------------------------------------------

    local height = 60 + (#categories * 28)

    f:SetSize(280, height)

    --------------------------------------------------------
    -- CATEGORY BUTTONS
    --------------------------------------------------------

    for i, cat in ipairs(categories) do

        local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")

        btn:SetSize(240, 24)
        btn:SetPoint("TOP", 0, -30 - (i - 1) * 28)

        btn:SetText(cat)

        btn:SetScript("OnClick", function()
            GA:ShowCategoryLines(cat, triggerMsg)
        end)

        table.insert(buttons, btn)
    end

    --------------------------------------------------------
    -- POSITION AT CURSOR
    --------------------------------------------------------

    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()

    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)

    f:Show()
end