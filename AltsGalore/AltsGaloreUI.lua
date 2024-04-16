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
        self.uiFrame.summaryTab.tabButton:SetScript("OnClick", function()
            self.selectedTab = "AltsGaloreUiSummaryTab"
            self:UpdateTabButtons()
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
        end)
        tinsert(self.uiFrame.tabList, "AltsGaloreUiGuildBankTab")

end

AG:CreateUI()

--------------- Frame functions for misc menu standalone button---------------
function AG:GetContainer(tab)
    if tab == "AltsGaloreUiContainersTab" then
        if  self.selectedBag[tab] == 1 then 
            return 1, 5, self.containersDB, self.selectedCharacter
        elseif self.selectedBag[tab] == 2 then
            return 6, 13, self.containersDB, self.selectedCharacter
        elseif self.selectedBag[tab] >= 3 then
            return self.selectedBag[tab] - 2, self.selectedBag[tab] - 2, self.personalBanksDB, self.selectedCharacter
        end
    elseif tab == "AltsGaloreUiRealmBankTab" then
        return self.selectedBag[tab], self.selectedBag[tab], self.realmBanksDB, "RealmBank"
    elseif tab == "AltsGaloreUiGuildBankTab" then
        return self.selectedBag[tab], self.selectedBag[tab], self.guildBanksDB, self.selectedGuild
    end
end

function AG:UiOnShow()
    SetPortraitTexture(self.uiFrame.portrait, "player")
    self.uiFrame:Show()
end

function AG:SetScrollFrame()
    self.selectedBag[self.selectedTab] = self.selectedBag[self.selectedTab] or 1
    local firstBag, lastBag, db, selection = self:GetContainer(self.selectedTab)
    if not db then return end
    self.uiFrame.SelectionScrollFrame:SetParent(self.selectedTab)
    self:ContainerScrollFrameUpdate(self:SetupContainerTable(db[selection], firstBag, lastBag))
    self:SelectionScrollFrameUpdate()
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
    self:SetScrollFrame()
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


------------------ScrollFrameTooltips---------------------------
function AG:ContainersTabsCreate()

	--ScrollFrame

	local ROW_HEIGHT = 16   -- How tall is each row?
	local MAX_ROWS = 33      -- How many rows can be shown at once?

	self.uiFrame.SelectionScrollFrame = CreateFrame("Frame", "AltsGaloreSelectionScrollFrame", AltsGaloreUiContainersTab)
	self.uiFrame.SelectionScrollFrame:EnableMouse(true)
	self.uiFrame.SelectionScrollFrame:SetPoint("BOTTOMLEFT", 16, 16)
	self.uiFrame.SelectionScrollFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	self.uiFrame.SelectionScrollFrame.lable = self.uiFrame.SelectionScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.SelectionScrollFrame.lable:SetJustifyH("LEFT")
	self.uiFrame.SelectionScrollFrame.lable:SetPoint("TOPLEFT", self.uiFrame.SelectionScrollFrame, 2, 15)

    local function getChars(tab)
        if not tab then return end
        local container, selection, text
        if self.selectedTab == "AltsGaloreUiContainersTab" then
            container = self.containersDB
            selection = "selectedCharacter"
            text = "Character Selection"
        elseif self.selectedTab == "AltsGaloreUiRealmBankTab" then
            container = self.realmBanksDB
            self.realBankSelected = "RealmBank"
            selection = "realBankSelected"
            text = "RealBank Selection"
        elseif self.selectedTab == "AltsGaloreUiGuildBankTab" then
            container = self.guildBanksDB
            selection = "selectedGuild"
            text = "Guild Selection"
        end
        local charList = {}
        for char, _ in pairs (container) do
            tinsert(charList, char)
        end
        return charList, selection, text
    end

	function AG:SelectionScrollFrameUpdate()
        local charList, selection, text = getChars(self.selectedTab)
        if not charList or not selection then return end
        self.uiFrame.SelectionScrollFrame.lable:SetText(text)
		local maxValue = #charList
		FauxScrollFrame_Update(self.uiFrame.SelectionScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(self.uiFrame.SelectionScrollFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
			self.uiFrame.SelectionScrollFrame.rows[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
			self.uiFrame.SelectionScrollFrame.rows[i]:SetChecked(false)
			if value <= maxValue then
				local row = self.uiFrame.SelectionScrollFrame.rows[i]
                row.Text:SetText(charList[value])
				row:SetScript("OnClick", function()
                    self[selection] = charList[value]
                    self.uiFrame.characterSelect:SetText(self[selection])
                    self:UpdateTabButtons()
                    self:SetScrollFrame()
					self:SelectionScrollFrameUpdate()
				end)
                if charList[value] == self[selection] then
				    row:SetChecked(true)
                end
                row:Show()
            else
                self.uiFrame.SelectionScrollFrame.rows[i]:Hide()
			end
		end
	end

	self.uiFrame.SelectionScrollFrame.scrollBar = CreateFrame("ScrollFrame", "AltsGaloreSelectionScrollFrameScrollBar", self.uiFrame.SelectionScrollFrame, "FauxScrollFrameTemplate")
	self.uiFrame.SelectionScrollFrame.scrollBar:SetPoint("TOPLEFT", 0, -8)
	self.uiFrame.SelectionScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -30, 8)
	self.uiFrame.SelectionScrollFrame.scrollBar:SetScript("OnVerticalScroll", function(scroll, offset)
		scroll.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		self:SelectionScrollFrameUpdate()
	end)

	local rows = setmetatable({}, { __index = function(t, i)
		local row = CreateFrame("CheckButton", "$parentRow"..i, self.uiFrame.SelectionScrollFrame )
		row:SetSize(140, ROW_HEIGHT)
		row:SetNormalFontObject(GameFontHighlightLeft)
        row:SetCheckedTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		row.Text = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
		row.Text:SetSize(140, ROW_HEIGHT)
		row.Text:SetPoint("LEFT",row)
        row.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
		row.Text:SetJustifyH("LEFT")
		if i == 1 then
			row:SetPoint("TOPLEFT", self.uiFrame.SelectionScrollFrame, 8, -8)
		else
			row:SetPoint("TOPLEFT", self.uiFrame.SelectionScrollFrame.rows[i-1], "BOTTOMLEFT")
		end
		rawset(t, i, row)
		return row
	end })

	self.uiFrame.SelectionScrollFrame.rows = rows

-------------------Container Scroll Frame-------------------

local EMPTY_SLOT = "Interface\\PaperDoll\\UI-Backpack-EmptySlot"
local BANK_BUTTON = "Interface\\Icons\\INV_Box_03"
local BAG_TEXTURE = "Interface\\Buttons\\Button-Backpack-Up"
local ROW_HEIGHT = 36   -- How tall is each row?
local MAX_ROWS = 11      -- How many rows can be shown at once?
local MAX_COLUMNS = 15

function AG:SetupContainerTable(db, firstBag, lastBag)
    if not db then return end
    firstBag = firstBag or 1
    lastBag = lastBag or 13
    local sorted = {[1] = {}}
        local cNum = 1
        for bagNum, bags in pairs(db) do
            if bags.numSlots and  (bagNum >= firstBag) and (bagNum <= lastBag) then
                for bag = 1, bags.numSlots do
                    if #sorted[cNum] == MAX_COLUMNS then tinsert(sorted, {}) cNum = cNum + 1 end
                    if bags[bag] and type(bags[bag]) == "table" then

                        tinsert(sorted[cNum], bags[bag])
                    else
                        tinsert(sorted[cNum], "EmptySlot")
                    end
                end
            end
        end
    return sorted
end


------------------ScrollFrameTooltips---------------------------
	local function ItemTemplate_OnEnter(self)
		if not self.itemLink then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
		GameTooltip:SetHyperlink(self.itemLink)
		GameTooltip:Show()
	end

	local function ItemTemplate_OnLeave()
		GameTooltip:Hide()
	end

	self.uiFrame.containerScrollFrame = CreateFrame("Frame", "AltsGaloreContainerScrollFrame", self.uiFrame.SelectionScrollFrame)
	self.uiFrame.containerScrollFrame:EnableMouse(true)
	self.uiFrame.containerScrollFrame:SetSize((ROW_HEIGHT + 13) * (MAX_COLUMNS), (ROW_HEIGHT + 12) * (MAX_ROWS))
    self.uiFrame.containerScrollFrame:SetPoint("LEFT", self.uiFrame.SelectionScrollFrame, "RIGHT", 0, 0)
	self.uiFrame.containerScrollFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	self.uiFrame.containerScrollFrame.lable = self.uiFrame.containerScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.containerScrollFrame.lable:SetJustifyH("LEFT")
	self.uiFrame.containerScrollFrame.lable:SetPoint("TOPLEFT", self.uiFrame.containerScrollFrame, 2, 15)
	self.uiFrame.containerScrollFrame.lable:SetText("Bags")

    local currentDB
	function AG:ContainerScrollFrameUpdate(db)
        if not db and not currentDB then return end
        currentDB = db or currentDB
		local maxValue = #currentDB
		FauxScrollFrame_Update(self.uiFrame.containerScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(self.uiFrame.containerScrollFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
            local row = self.uiFrame.containerScrollFrame.rows[i]
			if value <= maxValue then
                if i == 1 then
                    row:SetPoint("TOPLEFT", self.uiFrame.containerScrollFrame, 20, -20)
                else
                    row:SetPoint("BOTTOM", self.uiFrame.containerScrollFrame.rows[i-1], 0, -45)
                end
                for num = 1, MAX_COLUMNS do
                    local button = self.uiFrame.containerScrollFrame.rows[i]["button"..num]
                    if num == 1 then
                        button:SetPoint("LEFT", row, 0, 0)
                    else
                        button:SetPoint("LEFT", self.uiFrame.containerScrollFrame.rows[i]["button"..num-1], "RIGHT", 10, 0)
                    end
                    button:Show()
                    if currentDB[value][num] == "EmptySlot" then
                        button.itemTexture, button.count, button.quality, button.itemLink = EMPTY_SLOT, nil, nil, nil
                    elseif not currentDB[value][num] then
                        button:Hide()
                    else
                        local item = Item:CreateFromID(currentDB[value][num][1])
                        local itemCount = MAX_COLUMNS
                        if not item:GetInfo() then
                            item:ContinueOnLoad(function()
                                itemCount = itemCount - 1
                                if itemCount == 0 then
                                    self:ContainerScrollFrameUpdate()
                                end
                            end)
                        else
                            local itemData = {GetItemInfo(currentDB[value][num][1])}
                            button.itemLink, button.itemTexture, button.quality = itemData[2], itemData[10], itemData[3]
                            button.count = currentDB[value][num][2]
                            itemCount = itemCount - 1
                        end
                    end

                    _G[button:GetName().."IconTexture"]:SetSize(ROW_HEIGHT,ROW_HEIGHT)
                    _G[button:GetName().."IconTexture"]:SetAllPoints(button)
                    SetItemButtonTexture(button, button.itemTexture)
                    SetItemButtonQuality(button, button.quality)
                    SetItemButtonCount(button, button.count)
                    button:SetScript("OnClick", function()
                    end)
                end

				row:Show()
            else
                row:Hide()
			end
		end
	end

	self.uiFrame.containerScrollFrame.scrollBar = CreateFrame("ScrollFrame", "AltsGaloreContainerScrollFrameScrollBar", self.uiFrame.containerScrollFrame, "FauxScrollFrameTemplate")
	self.uiFrame.containerScrollFrame.scrollBar:SetPoint("TOPLEFT", 0, -8)
	self.uiFrame.containerScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -30, 8)
	self.uiFrame.containerScrollFrame.scrollBar:SetScript("OnVerticalScroll", function(scroll, offset)
		scroll.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		self:ContainerScrollFrameUpdate()
	end)

	local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Frame", "$parentRow"..i, self.uiFrame.containerScrollFrame)
        row:SetSize(ROW_HEIGHT * MAX_COLUMNS + 0.5, ROW_HEIGHT)
		for num = 1, MAX_COLUMNS do
            row["button"..num] = CreateFrame("Button", "$parentButton"..num, row , "ItemButtonTemplate")
            row["button"..num]:SetSize(ROW_HEIGHT, ROW_HEIGHT)
            row["button"..num]:SetScript("OnShow", function(button)
                if GameTooltip:GetOwner() == button:GetName() then
                    ItemTemplate_OnEnter(button)
                end
            end)
            row["button"..num]:SetScript("OnEnter", function(button)
                ItemTemplate_OnEnter(button)
            end)
            row["button"..num]:SetScript("OnLeave", ItemTemplate_OnLeave)
        end
		rawset(t, i, row)
		return row
	end })

	self.uiFrame.containerScrollFrame.rows = rows

    self.uiFrame.tabSelectionFrame = CreateFrame("Frame", "AltsGaloreTabSelectionFrame", self.uiFrame.containerScrollFrame)
    self.uiFrame.tabSelectionFrame:EnableMouse(true)
    self.uiFrame.tabSelectionFrame:SetSize(176, self.uiFrame.containerScrollFrame:GetHeight())
    self.uiFrame.tabSelectionFrame:SetPoint("LEFT",self.uiFrame.containerScrollFrame, "RIGHT", 0, 0)
    self.uiFrame.tabSelectionFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    self.uiFrame.tabSelectionFrame.buttons = {}
    for num = 1, 8 do
        self.uiFrame.tabSelectionFrame.buttons[num] = CreateFrame("CheckButton", "$parentButton"..num, self.uiFrame.tabSelectionFrame)
        local button = self.uiFrame.tabSelectionFrame.buttons[num]
        button.tooltipText = ""
        button:SetSize(150, 36)
        if num == 1 then
            button:SetPoint("TOP" , self.uiFrame.tabSelectionFrame ,0 ,-10)
        else
            button:SetPoint("TOP", self.uiFrame.tabSelectionFrame.buttons[num - 1],"BOTTOM", 0 ,-5)
        end
        button:SetScript("OnClick", function(button)
            self.selectedBag[self.selectedTab] = num
            self:UpdateTabButtons()
            self:SetScrollFrame()
        end)
        button.icon = button:CreateTexture(nil, "ARTWORK")
        button.icon:SetSize(36,36)
        button.icon:SetPoint("LEFT", button,0,0)
        button.Text = button:CreateFontString()
        button.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
        button.Text:SetFontObject(GameFontNormal)
        button.Text:SetPoint("LEFT", button.icon, "RIGHT", 5, 0)
        button:SetCheckedTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    end

    self.uiFrame.SelectionScrollFrame:SetSize(150, self.uiFrame.containerScrollFrame:GetHeight())

    function AG:SetContainerSelectionInfo(tab)
        local tabInfo = {}
        local db
        if tab == "AltsGaloreUiContainersTab" then
            tinsert(tabInfo, {name = "Bags", icon = BAG_TEXTURE})
            tinsert(tabInfo,{name = "Bank", icon = BANK_BUTTON})
            db = self.personalBanksDB[self.selectedCharacter]
       
        elseif tab == "AltsGaloreUiRealmBankTab" then
            db = self.realmBanksDB["RealmBank"]
        elseif tab == "AltsGaloreUiGuildBankTab" then
            db = self.guildBanksDB[self.selectedGuild]
        end
        for _, bag in pairs(db) do
            if bag then
                tinsert(tabInfo, {name = bag.name, icon = bag.icon})
            end
        end
        return tabInfo

    end
    self.selectedBag = {}
    function AG:UpdateTabButtons()
        self.selectedBag[self.selectedTab] = self.selectedBag[self.selectedTab] or 1
        local containerInfo = self:SetContainerSelectionInfo(self.selectedTab)
        if not containerInfo then return end
        for i = 1, 8 do
            local button = self.uiFrame.tabSelectionFrame.buttons[i]
            button:Hide()
            button:SetChecked(false)
            if containerInfo and containerInfo[i] then
                button.icon:SetTexture(containerInfo[i].icon)
                button.Text:SetText(containerInfo[i].name)
                button.tooltipText = containerInfo[i].name
                button:Show()
            end
            if self.selectedBag[self.selectedTab] == i then
                button:SetChecked(true)
            end
        end

    end

end

AG:ContainersTabsCreate()