local _, private = ...

-- [[ Core ]]
local Aurora = private.Aurora
local Base, Hook, Skin = Aurora.Base, Aurora.Hook, Aurora.Skin
local Color = Aurora.Color

do --[[ AddOns\Blizzard_TokenUI\Blizzard_TokenUI.lua ]]
    function Hook.TokenFrame_Update()
        local buttons = _G.TokenFrameContainer.buttons
        if not buttons then return end

        for i = 1, #buttons do
            local button = buttons[i]

            local r, g, b = Color.highlight:GetRGB()
            button.highlight:SetColorTexture(r, g, b, 0.2)
            button.highlight:SetPoint("TOPLEFT", 1, 0)
            button.highlight:SetPoint("BOTTOMRIGHT", -1, 0)

            if button.isHeader then
                button._auroraBG:Show()
                button._auroraMinus:Show()
                button._auroraPlus:SetShown(not button.isExpanded)
            else
                button._auroraBG:Hide()
                button._auroraMinus:Hide()
                button._auroraPlus:Hide()
            end
        end
    end
end

do --[[ AddOns\Blizzard_TokenUI\Blizzard_TokenUI.xml ]]
    function Skin.TokenButtonTemplate(Button)
        local stripe = Button.stripe
        stripe:SetPoint("TOPLEFT", 1, 1)
        stripe:SetPoint("BOTTOMRIGHT", -1, -1)

        Base.CropIcon(Button.icon, Button)

        Button.categoryMiddle:SetAlpha(0)
        Button.categoryLeft:SetAlpha(0)
        Button.categoryRight:SetAlpha(0)

        local layer, subLevel = Button.categoryMiddle:GetDrawLayer()
        local bg = Button:CreateTexture(nil, layer, subLevel + 3)
        bg:SetColorTexture(Color.button:GetRGB())
        bg:SetAllPoints()
        Button._auroraBG = bg

        Button.expandIcon:SetTexture("")
        local minus = Button:CreateTexture(nil, "ARTWORK")
        minus:SetSize(7, 1)
        minus:SetPoint("LEFT", 8, 0)
        minus:SetColorTexture(1, 1, 1)
        minus:Hide()
        Button._auroraMinus = minus

        local plus = Button:CreateTexture(nil, "ARTWORK")
        plus:SetSize(1, 7)
        plus:SetPoint("LEFT", 11, 0)
        plus:SetColorTexture(1, 1, 1)
        plus:Hide()
        Button._auroraPlus = plus
    end
    function Skin.BackpackTokenTemplate(Button)
        Base.CropIcon(Button.icon, Button)
    end
end

function private.AddOns.Blizzard_TokenUI()
    _G.hooksecurefunc("TokenFrame_Update", Hook.TokenFrame_Update)
    _G.hooksecurefunc(_G.TokenFrameContainer, "update", Hook.TokenFrame_Update)


    Skin.HybridScrollBarTemplate(_G.TokenFrameContainer.scrollBar)


    Base.SetBackdrop(_G.TokenFramePopup)
    _G.TokenFramePopup:SetSize(175, 90)

    local titleText = _G.TokenFramePopupTitle
    titleText:ClearAllPoints()
    titleText:SetPoint("TOPLEFT")
    titleText:SetPoint("BOTTOMRIGHT", _G.TokenFramePopup, "TOPRIGHT", 0, -private.FRAME_TITLE_HEIGHT)

    _G.TokenFramePopupCorner:Hide()

    Skin.OptionsSmallCheckButtonTemplate(_G.TokenFramePopupInactiveCheckBox)
    _G.TokenFramePopupInactiveCheckBox:SetPoint("TOPLEFT", _G.TokenFramePopup, 24, -26)
    Skin.OptionsSmallCheckButtonTemplate(_G.TokenFramePopupBackpackCheckBox)
    _G.TokenFramePopupBackpackCheckBox:SetPoint("TOPLEFT", _G.TokenFramePopupInactiveCheckBox, "BOTTOMLEFT", 0, -8)

    Skin.UIPanelCloseButton(_G.TokenFramePopupCloseButton)

    if not private.disabled.bags then
        local BackpackTokenFrame = _G.BackpackTokenFrame
        BackpackTokenFrame:GetRegions():Hide()

        local tokenBG = _G.CreateFrame("Frame", nil, BackpackTokenFrame)
        Base.SetBackdrop(tokenBG, Color.frame)
        tokenBG:SetBackdropBorderColor(0.15, 0.95, 0.15)
        tokenBG:SetPoint("TOPLEFT", 5, -6)
        tokenBG:SetPoint("BOTTOMRIGHT", -9, 8)

        for i = 1, #BackpackTokenFrame.Tokens do
            Skin.BackpackTokenTemplate(BackpackTokenFrame.Tokens[i])
        end
    end
end
