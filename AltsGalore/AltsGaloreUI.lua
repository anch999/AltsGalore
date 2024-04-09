local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local CYAN =  "|cff00ffff"
local LIMEGREEN = "|cFF32CD32"
--------------- Creates the main misc menu standalone button ---------------

function AG:CreateUI()
        -------------------Main Frame-------------------
        self.uiFrame = CreateFrame("FRAME", "AltsGaloreUI", UIParent, "PortraitFrameTemplate")
        self.uiFrame:SetPoint("CENTER",0,0)
        self.uiFrame:SetSize(1105,640)
        self.uiFrame:EnableMouse(true)
        self.uiFrame:SetMovable(true)
        self.uiFrame:SetFrameStrata("HIGH")
        self.uiFrame.TitleText:SetText("AltsGalore")
        self.uiFrame:RegisterForDrag("LeftButton")
        self.uiFrame:EnableKeyboard(true)
        self.uiFrame:SetToplevel(true)
        self.uiFrame:Hide()
        self.uiFrame:SetScript("OnShow", function() self:UiOnShow() end)
        self.uiFrame:SetScript("OnMouseDown", function()
            AG.dewdrop:Close()
            --AGDefaultFrameSearchBox:ClearFocus()
        end)
        self.uiFrame:SetScript("OnHide", function() AG.dewdrop:Close() end)
        self.uiFrame:SetScript("OnDragStart", function()
            self.uiFrame:StartMoving()
        end)
        self.uiFrame:SetScript("OnDragStop", function()
            self.uiFrame:StopMovingOrSizing()
         end)

        self.uiFrame.tabList = {}
         -------------------First Tab Frame-------------------
        self.uiFrame.summaryTab = CreateFrame("Frame", "AltsGaloreUiSummaryTab", self.uiFrame)
        self.uiFrame.summaryTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiSummaryTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.summaryTab.tabButton:SetPoint("BOTTOMLEFT", 5, -30)
        self.uiFrame.summaryTab.tabButton:SetWidth(125)
        self.uiFrame.summaryTab.tabButton.Text:SetText("Account")
        self.uiFrame.summaryTab.tabButton.Icon:SetIcon("Interface\\Icons\\INV_Scroll_09")
        self.uiFrame.summaryTab.tabButton:SetScript("OnClick", function() self:SetFrameTab("AltsGaloreUiSummaryTab") end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiSummaryTab")

        -------------------Bags Tab Frame-------------------
        self.uiFrame.bagsTab = CreateFrame("Frame", "AltsGaloreUiBagsTab", self.uiFrame)
        self.uiFrame.bagsTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiBagsTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.bagsTab.tabButton:SetPoint("LEFT", self.uiFrame.summaryTab.tabButton, "RIGHT", 10, 0)
        self.uiFrame.bagsTab.tabButton:SetWidth(125)
        self.uiFrame.bagsTab.tabButton.Text:SetText("Bags")
        self.uiFrame.bagsTab.tabButton.Icon:SetIcon("Interface\\Icons\\INV_Misc_Bag_08")
        self.uiFrame.bagsTab.tabButton:SetScript("OnClick", function() self:SetFrameTab("AltsGaloreUiBagsTab") end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiBagsTab")

        -------------------Bank Tab Frame-------------------
        self.uiFrame.bankTab = CreateFrame("Frame", "AltsGaloreUiBankTab", self.uiFrame)
        self.uiFrame.bankTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiBankTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.bankTab.tabButton:SetPoint("LEFT", self.uiFrame.bagsTab.tabButton, "RIGHT", 10, 0)
        self.uiFrame.bankTab.tabButton:SetWidth(125)
        self.uiFrame.bankTab.tabButton.Text:SetText("Bank")
        self.uiFrame.bankTab.tabButton.Icon:SetIcon("Interface\\Icons\\INV_Misc_Bag_08")
        self.uiFrame.bankTab.tabButton:SetScript("OnClick", function() self:SetFrameTab("AltsGaloreUiBankTab") end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiBankTab")

        -------------------Personal Bank Tab Frame-------------------
        self.uiFrame.personalBankTab = CreateFrame("Frame", "AltsGaloreUiPersonalBankTab", self.uiFrame)
        self.uiFrame.personalBankTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiPersonalBankTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.personalBankTab.tabButton:SetPoint("LEFT", self.uiFrame.bankTab.tabButton, "RIGHT", 10, 0)
        self.uiFrame.personalBankTab.tabButton:SetWidth(125)
        self.uiFrame.personalBankTab.tabButton.Text:SetText("Personal Bank")
        self.uiFrame.personalBankTab.tabButton.Icon:SetIcon("Interface\\Icons\\achievement_guildperk_mobilebanking")
        self.uiFrame.personalBankTab.tabButton:SetScript("OnClick", function() self:SetFrameTab("AltsGaloreUiPersonalBankTab") end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiPersonalBankTab")

        -------------------Realm Bank Tab Frame-------------------
        self.uiFrame.realmBankTab = CreateFrame("Frame", "AltsGaloreUiRealmBankTab", self.uiFrame)
        self.uiFrame.realmBankTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiRealmBankTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.realmBankTab.tabButton:SetPoint("LEFT", self.uiFrame.personalBankTab.tabButton, "RIGHT", 10, 0)
        self.uiFrame.realmBankTab.tabButton:SetWidth(125)
        self.uiFrame.realmBankTab.tabButton.Text:SetText("Realm Bank")
        self.uiFrame.realmBankTab.tabButton.Icon:SetIcon("Interface\\Icons\\achievement_guildperk_mobilebanking")
        self.uiFrame.realmBankTab.tabButton:SetScript("OnClick", function() self:SetFrameTab("AltsGaloreUiRealmBankTab") end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiRealmBankTab")

        -------------------Guild Bank Tab Frame-------------------
        self.uiFrame.guildBankTab = CreateFrame("Frame", "AltsGaloreUiGuildBankTab", self.uiFrame)
        self.uiFrame.guildBankTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiGuildBankTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.guildBankTab.tabButton:SetPoint("LEFT", self.uiFrame.realmBankTab.tabButton, "RIGHT", 10, 0)
        self.uiFrame.guildBankTab.tabButton:SetWidth(125)
        self.uiFrame.guildBankTab.tabButton.Text:SetText("Guild Bank")
        self.uiFrame.guildBankTab.tabButton.Icon:SetIcon("Interface\\Icons\\achievement_guildperk_mobilebanking")
        self.uiFrame.guildBankTab.tabButton:SetScript("OnClick", function() self:SetFrameTab("AltsGaloreUiGuildBankTab") end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiGuildBankTab")

end

AG:CreateUI()

--------------- Frame functions for misc menu standalone button---------------

function AG:UiOnShow()
    SetPortraitTexture(self.uiFrame.portrait, "player")
    self.uiFrame:Show()
end


function AG:SetFrameTab(frame)
    self.uiFrame.currentTab = frame
    for _, tab in pairs(self.uiFrame.tabList) do
        if tab ~= frame then
            _G[tab.."Button"]:SetChecked(false)
            _G[tab.."Button"]:UpdateButton()
            _G[tab]:Hide()
        end
    end

    _G[frame.."Button"]:SetChecked(true)
    _G[frame.."Button"]:UpdateButton()
    _G[frame]:Show()
end