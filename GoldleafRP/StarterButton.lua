GoldleafRP = GoldleafRP or {}
local GA = GoldleafRP

function GA:CreateStarterButton()
    if _G.GoldleafStarterButton then return end

    local button = CreateFrame("Button", "GoldleafStarterButton", UIParent, "UIPanelButtonTemplate")
    button:SetSize(110, 28)
    button:SetText("RP Starter")
    button:SetPoint("CENTER", UIParent, "CENTER", 0, -200)

    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", button.StartMoving)
    button:SetScript("OnDragStop", button.StopMovingOrSizing)
    button:SetClampedToScreen(true)

    button:SetScript("OnClick", function()

        if not GA.activeCharacter then
            DEFAULT_CHAT_FRAME:AddMessage("|cff7CFC00[Goldleaf]|r No active Goldleaf character.")
            return
        end

        ----------------------------------------------------------------
        -- If ReplyBox is NOT open, open it manually
        ----------------------------------------------------------------
        if not (GoldleafReplyBox and GoldleafReplyBox:IsShown()) then
            GA:ShowReplyBox(nil)
            return
        end

        ----------------------------------------------------------------
        -- If ReplyBox IS already open, use normal RP Starter behavior
        ----------------------------------------------------------------
        local line = GA:GetNextStarter()

        local editBox = ChatEdit_ChooseBoxForSend() or ChatFrame1EditBox
        if editBox then
            ChatEdit_ActivateChat(editBox)
            editBox:SetText(line)
        end
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Goldleaf RP Helper")
        GameTooltip:AddLine("Click once to open Reply Categories.", 1, 1, 1)
        GameTooltip:AddLine("Click again while ReplyBox is open to generate an RP Starter.", 1, 1, 1)
        GameTooltip:AddLine("Drag to move.", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", GameTooltip_Hide)
end
