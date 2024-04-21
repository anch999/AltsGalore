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
        end)
        self.uiFrame:SetScript("OnHide", function() AG.dewdrop:Close() end)
        self.uiFrame:SetScript("OnDragStart", function()
            self.uiFrame:StartMoving()
        end)
        self.uiFrame:SetScript("OnDragStop", function()
            self.uiFrame:StopMovingOrSizing()
        end)

        --Character Select Button
        self.uiFrame.characterSelect = CreateFrame("Button", "AltsGaloreCharacterSelect", self.uiFrame, "AltsGaloreDropMenuTemplate")
        self.uiFrame.characterSelect:SetSize(150,25)
        self.uiFrame.characterSelect:SetPoint("TOPLEFT", self.uiFrame,60,-60)
        self.uiFrame.characterSelect.Lable:SetText("Select Character")
        self.uiFrame.characterSelect:SetScript("OnClick", function(button)
            self:DewdropRegister(button)
        end)
        self.uiFrame.characterSelect:Hide()
        self.selectedTab = "AltsGaloreUiSummaryTab"
        self.uiFrame.tabList = {}
         -------------------First Tab Frame-------------------
        self.uiFrame.summaryTab = CreateFrame("Frame", "AltsGaloreUiSummaryTab", self.uiFrame)
        self.uiFrame.summaryTab:SetPoint("CENTER")
        self.uiFrame.summaryTab:SetSize(self.uiFrame:GetWidth()-10,self.uiFrame:GetHeight()-10)
        self.uiFrame.summaryTab:Hide()
        self.uiFrame.summaryTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiSummaryTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.summaryTab.tabButton:SetPoint("BOTTOMLEFT", 5, -30)
        self.uiFrame.summaryTab.tabButton:SetWidth(125)
        self.uiFrame.summaryTab.tabButton.Text:SetText("Account")
        self.uiFrame.summaryTab.tabButton.Icon:SetIcon("Interface\\Icons\\INV_Scroll_09")
        self.uiFrame.summaryTab:SetScript("OnShow", function()
            self.selectedTab = "AltsGaloreUiSummaryTab"
        end)
        self.uiFrame.summaryTab.tabButton:SetScript("OnClick", function()
            self.selectedTab = "AltsGaloreUiSummaryTab"
            self:SetFrameTab()
        end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiSummaryTab")

        -------------------Bags Tab Frame-------------------
        self.uiFrame.containersTab = CreateFrame("Frame", "AltsGaloreUiContainersTab", self.uiFrame)
        self.uiFrame.containersTab:SetPoint("CENTER")
        self.uiFrame.containersTab:SetSize(self.uiFrame:GetWidth()-10,self.uiFrame:GetHeight()-10)
        self.uiFrame.containersTab:Hide()
        self.uiFrame.containersTab:SetScript("OnShow", function()
            self.selectedTab = "AltsGaloreUiContainersTab"
            self:UpdateTabButtons()
            self:SetScrollFrame()
        end)
        self.uiFrame.containersTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiContainersTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.containersTab.tabButton:SetPoint("LEFT", self.uiFrame.summaryTab.tabButton, "RIGHT", 10, 0)
        self.uiFrame.containersTab.tabButton:SetWidth(125)
        self.uiFrame.containersTab.tabButton.Text:SetText("Containers")
        self.uiFrame.containersTab.tabButton.Icon:SetIcon("Interface\\Buttons\\Button-Backpack-Up")
        self.uiFrame.containersTab.tabButton:SetScript("OnClick", function()
            self.selectedTab = "AltsGaloreUiContainersTab"
            self:UpdateTabButtons()
            self:SetFrameTab()
            self:SetScrollFrame()
        end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiContainersTab")

        -------------------Realm Bank Tab Frame-------------------
        self.uiFrame.realmBankTab = CreateFrame("Frame", "AltsGaloreUiRealmBankTab", self.uiFrame)
        self.uiFrame.realmBankTab:SetPoint("CENTER")
        self.uiFrame.realmBankTab:SetSize(self.uiFrame:GetWidth()-10,self.uiFrame:GetHeight()-10)
        self.uiFrame.realmBankTab:Hide()
        self.uiFrame.realmBankTab:SetScript("OnShow", function()
            self.selectedTab = "AltsGaloreUiRealmBankTab"
            self:UpdateTabButtons()
            self:SetScrollFrame()
        end)
        self.uiFrame.realmBankTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiRealmBankTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.realmBankTab.tabButton:SetPoint("LEFT", self.uiFrame.containersTab.tabButton, "RIGHT", 10, 0)
        self.uiFrame.realmBankTab.tabButton:SetWidth(125)
        self.uiFrame.realmBankTab.tabButton.Text:SetText("Realm Bank")
        self.uiFrame.realmBankTab.tabButton.Icon:SetIcon("Interface\\Icons\\achievement_guildperk_mobilebanking")
        self.uiFrame.realmBankTab.tabButton:SetScript("OnClick", function()
            self.selectedTab = "AltsGaloreUiRealmBankTab"
            self:UpdateTabButtons()
            self:SetFrameTab()
            self:SetScrollFrame()
        end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiRealmBankTab")

        -------------------Guild Bank Tab Frame-------------------
        self.uiFrame.guildBankTab = CreateFrame("Frame", "AltsGaloreUiGuildBankTab", self.uiFrame)
        self.uiFrame.guildBankTab:SetPoint("CENTER")
        self.uiFrame.guildBankTab:SetSize(self.uiFrame:GetWidth()-10,self.uiFrame:GetHeight()-10)
        self.uiFrame.guildBankTab:Hide()
        self.uiFrame.guildBankTab:SetScript("OnShow", function()
            self.selectedTab = "AltsGaloreUiGuildBankTab"
            self:UpdateTabButtons()
            self:SetScrollFrame()
        end)
        self.uiFrame.guildBankTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiGuildBankTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.guildBankTab.tabButton:SetPoint("LEFT", self.uiFrame.realmBankTab.tabButton, "RIGHT", 10, 0)
        self.uiFrame.guildBankTab.tabButton:SetWidth(125)
        self.uiFrame.guildBankTab.tabButton.Text:SetText("Guild Bank")
        self.uiFrame.guildBankTab.tabButton.Icon:SetIcon("Interface\\Icons\\achievement_guildperk_mobilebanking")
        self.uiFrame.guildBankTab.tabButton:SetScript("OnClick", function()
            self.selectedTab = "AltsGaloreUiGuildBankTab"
            self:UpdateTabButtons()
            self:SetFrameTab()
            self:SetScrollFrame()
        end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiGuildBankTab")
        
        -------------------Search Tab Frame-------------------
        self.uiFrame.searchTab = CreateFrame("Frame", "AltsGaloreUiSearchTab", self.uiFrame)
        self.uiFrame.searchTab:SetPoint("CENTER")
        self.uiFrame.searchTab:SetSize(self.uiFrame:GetWidth()-10,self.uiFrame:GetHeight()-10)
        self.uiFrame.searchTab:Hide()
        self.uiFrame.searchTab:SetScript("OnShow", function()
            self.selectedTab = "AltsGaloreUiSearchTab"
            self:SetFrameTab()
        end)
        self.uiFrame.searchTab.tabButton = CreateFrame("CheckButton", "AltsGaloreUiSearchTabButton", self.uiFrame, "AltsGaloreTabTemplate")
        self.uiFrame.searchTab.tabButton:SetPoint("LEFT", self.uiFrame.guildBankTab.tabButton, "RIGHT", 10, 0)
        self.uiFrame.searchTab.tabButton:SetWidth(125)
        self.uiFrame.searchTab.tabButton.Text:SetText("Search")
        self.uiFrame.searchTab.tabButton.Icon:Hide()
        self.uiFrame.searchTab.tabButton.IconAtlas = self.uiFrame.searchTab.tabButton:CreateTexture(nil, "ARTWORK")
        self.uiFrame.searchTab.tabButton.IconAtlas:SetPoint("LEFT", 10, 2)
        self.uiFrame.searchTab.tabButton.IconAtlas:SetSize(20,20)
        self.uiFrame.searchTab.tabButton.IconAtlas:SetAtlas("communities-icon-searchmagnifyingglass")
        self.uiFrame.searchTab.tabButton:SetScript("OnClick", function()
            self.selectedTab = "AltsGaloreUiSearchTab"
            self:SetFrameTab()
        end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiSearchTab")
            --Search Edit Box
        self.uiFrame.searchbox = CreateFrame("EditBox", "AltsGaloreUiSearchBox", self.uiFrame, "SearchBoxTemplate")
        self.uiFrame.searchbox:SetSize(190,30)
        self.uiFrame.searchbox:SetPoint("TOPLEFT", self.uiFrame, 75, -30)
        self.uiFrame.searchbox:SetScript("OnEnterPressed", function(editBox)
            self:FullSearch()
            editBox:ClearFocus()
        end)
        self.uiFrame.searchbox:SetScript("OnTextChanged", function(editBox)
            if editBox:HasFocus() then
                SearchBoxTemplate_OnTextChanged(editBox)
            end
        end)
        self.uiFrame.searchbox.clearButton:HookScript("OnClick", function()
            wipe(self.SearchResults)
            self:SearchScrollFrameUpdate()
        end)
end

AG:CreateUI()

--------------- Frame functions for misc menu standalone button---------------


function AG:UiOnShow()
    SetPortraitTexture(self.uiFrame.portrait, "player")
    self.uiFrame:Show()
end

function AG:SetFrameTab()
    for _, tab in pairs(self.uiFrame.tabList) do
        if tab ~= self.selectedTab then
            _G[tab.."Button"]:SetChecked(false)
            _G[tab.."Button"]:UpdateButton()
            _G[tab]:Hide()
        end
    end

    _G[self.selectedTab.."Button"]:SetChecked(true)
    _G[self.selectedTab.."Button"]:UpdateButton()
    _G[self.selectedTab]:Show()
end



--sets up the drop down menu for any menus
function AG:DewdropRegister(button)
    if self.dewdrop:IsOpen(button) then self.dewdrop:Close() return end
    self.dewdrop:Register(button,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            for name, char in pairs(self.containersDB) do
                self.dewdrop:AddLine(
                    'text', name,
                    'func', function()
                        self.selectedCharacter = name
                        self.uiFrame.characterSelect:SetText(self.selectedCharacter)
                        self:SetScrollFrame()
                    end,
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'closeWhenClicked', true,
                    'notCheckable', true
                )
            end
            self:AddDividerLine(35)
            self.dewdrop:AddLine(
				'text', "|cFF00FFFFClose Menu",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
				'closeWhenClicked', true,
				'notCheckable', true
			)
		end,
		'dontHook', true
	)
    self.dewdrop:Open(button)

    GameTooltip:Hide()
end

