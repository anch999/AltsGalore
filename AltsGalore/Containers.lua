local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local MAX_GUILDBANK_SLOTS_PER_TAB = 98

function AG:InitializeStorgeDBs()
    AltsGaloreContainersDB = AltsGaloreContainersDB or {}
    AltsGaloreGuildBanksDB = AltsGaloreGuildBanksDB or {}
    AltsGalorePersonalBanksDB =  AltsGalorePersonalBanksDB or {}
    AltsGaloreRealmBanksDB = AltsGaloreRealmBanksDB or {}

    local function setupDBs(db, addonDB, type)
        self[addonDB] = db[self.realm]
        if not type then return end
        if not db[self.realm] then db[self.realm] = {} end
        if not db[self.realm][type] then db[self.realm][type] = {} end
    end

    setupDBs(AltsGaloreContainersDB, "containersDB", self.thisChar)
    setupDBs(AltsGalorePersonalBanksDB, "personalBanksDB", self.thisChar)
    setupDBs(AltsGaloreGuildBanksDB, "guildBanksDB", self.guild)
    setupDBs(AltsGaloreRealmBanksDB, "realmBanksDB", "RealmBank")
    self:ScanContainer()
end

function AG:BAG_UPDATE(event, bagID)
    bagID = bagID + 1
	if bagID < 0 then return end
    if (bagID >= 6) and (bagID <= 13) and not self.bankFrameOpen then
		return
	end
    self:ScanContainer(bagID)
end

function AG:PLAYERBANKSLOTS_CHANGED()
    self:ScanContainer({6,13})
end

-- Scans the id of the bag/bank tab it is sent
function AG:ScanContainer(bagID)
    if not self.containersDB then return end
	local function bagInfo(bagID, storedBagID)
        if storedBagID == 1 or storedBagID == 6 then	-- Bag 0	
            return "Interface\\Buttons\\Button-Backpack-Up"
        else				-- Bags 1 through 11
            return GetInventoryItemTexture("player", ContainerIDToInventoryID(bagID)) , GetInventoryItemLink("player", ContainerIDToInventoryID(bagID))
        end
    end
	local function scanBag(bagID)
        local storedBagID = bagID
        if bagID == 13 then
            bagID = -1
            storedBagID = 6
        elseif bagID >= 6 then
            storedBagID = storedBagID + 1
            bagID = bagID - 1
        else
            bagID = bagID - 1
        end
        local numSlots = GetContainerNumSlots(bagID)

        if numSlots == 0 then return end
        local icon, itemLink = bagInfo(bagID, storedBagID)
        self.containersDB[self.thisChar][storedBagID] = {icon = icon, itemLink = itemLink, numSlots = numSlots}
        for slot = 1, numSlots do
            local itemCount = select(2,GetContainerItemInfo(bagID, slot))
            local itemID = GetContainerItemID(bagID, slot)
            if itemID then
                self.containersDB[self.thisChar][storedBagID][slot] = {itemID, itemCount}
            end
        end
    end
    -- scan bags
    if type(bagID) == "table" then
        for bag = bagID[1], bagID[2] do
            scanBag(bag)
        end
    elseif bagID then
        scanBag(bagID)
    else
        for bag = 1, 5 do
            scanBag(bag)
        end
    end
    if self.uiFrame.containerScrollFrame:IsVisible() and self.selectedCharacter == self.thisChar then
        self:SetScrollFrame()
    end
end
AG.numTabs = {}

-- Used to reset the current numTabs if bank type changes
local lastBankType
local function lastBank(last)
    if last ~= lastBankType then
        wipe(AG.numTabs)
        lastBankType = last
    end
end
function AG:GUILDBANKBAGSLOTS_CHANGED()
    local gBankType, containerType
    
    -- Set what db to save data to
    if self.IsPersonalBank then
        gBankType = "personalBanksDB"
        containerType = self.thisChar
    elseif self.IsRealmBank then
        gBankType = "realmBanksDB"
        containerType = "RealmBank"
    elseif self.guild then
        gBankType = "guildBanksDB"
        containerType = self.guild
    end
    local db = self[gBankType][containerType]

    -- updates the tabs saved data
    local function processTab(tab)
        if not tab then return end
        local name, icon = GetGuildBankTabInfo(tab)
        if db[tab] then table.wipe(db[tab]) end
        db[tab] = {name = name, icon = icon, numSlots = MAX_GUILDBANK_SLOTS_PER_TAB}

        for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
            local itemID = self:GetItemIdFromLink(GetGuildBankItemLink(tab, slot))
            local itemCount = select(2, GetGuildBankItemInfo(tab,slot))
            if itemID then
                db[tab][slot] = {itemID, itemCount}
            end
        end
    end

    local tab = GetCurrentGuildBankTab()
    
    lastBank(gBankType)
    self.numTabs[tab] = true
    -- refresh tabs that have been loaded since bank was opened
    for i, _ in pairs(self.numTabs) do
        processTab(i)
    end

    -- Refresh container scroll frame if the window is open
    if self.uiFrame.containerScrollFrame:IsVisible() and self.selectedCharacter == self.thisChar then
        self:SetScrollFrame()
    end

end

function AG:GetContainer(tab)
    if tab == "containersTab" then
        if  self.selectedBag[tab] == 1 then 
            return 1, 5, self.containersDB, self.selectedCharacter
        elseif self.selectedBag[tab] == 2 then
            return 6, 13, self.containersDB, self.selectedCharacter
        elseif self.selectedBag[tab] >= 3 then
            return self.selectedBag[tab] - 2, self.selectedBag[tab] - 2, self.personalBanksDB, self.selectedCharacter
        end
    elseif tab == "realmBankTab" then
        return self.selectedBag[tab], self.selectedBag[tab], self.realmBanksDB, "RealmBank"
    elseif tab == "guildBankTab" then
        return self.selectedBag[tab], self.selectedBag[tab], self.guildBanksDB, self.selectedGuild
    end
end

function AG:SetScrollFrame()
    self.selectedBag[self.selectedTab] = self.selectedBag[self.selectedTab] or 1
    local firstBag, lastBag, db, selection = self:GetContainer(self.selectedTab)
    if not db then return end
    self.uiFrame.SelectionScrollFrame:SetParent(self.uiFrame[self.selectedTab])
    self:ContainerScrollFrameUpdate(self:SetupContainerTable(db[selection], firstBag, lastBag))
    self:SelectionScrollFrameUpdate()
end

------------------Create Containers Scroll Frame---------------------------
function AG:ContainersTabsCreate()

	--ScrollFrame

	local ROW_HEIGHT = 16   -- How tall is each row?
	local MAX_ROWS = 33      -- How many rows can be shown at once?

	self.uiFrame.SelectionScrollFrame = CreateFrame("Frame", "AltsGaloreSelectionScrollFrame", self.uiFrame.containersTab)
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

    local function getChars()
        local containerSettings = {
            containersTab = {self.containersDB, "selectedCharacter", "Character Selection"},
            realmBankTab = {self.realmBanksDB, "realmBankSelected", "RealBank Selection"},
            guildBankTab = {self.guildBanksDB, "selectedGuild", "Guild Selection"},
        }
        local container = containerSettings[self.selectedTab]
        if not container then return end
        local charList = {}
        for char, _ in pairs (container[1]) do
            tinsert(charList, char)
        end
        return charList, container[2], container[3]
    end

	function AG:SelectionScrollFrameUpdate()
        local charList, selection, text = getChars()
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
                    self.selectedBag[self.selectedTab] = 1
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

    function AG:HideContainerRows()
        for i = 1, MAX_ROWS do
            self.uiFrame.containerScrollFrame.rows[i]:Hide()
        end
    end

    local currentDB
	function AG:ContainerScrollFrameUpdate(db)
        AG:HideContainerRows()
        if not db and not currentDB then return end
        currentDB = db or currentDB
		local maxValue = #currentDB
		FauxScrollFrame_Update(self.uiFrame.containerScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(self.uiFrame.containerScrollFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
            local row = self.uiFrame.containerScrollFrame.rows[i]
			if maxValue ~= 0 and value <= maxValue then
                if i == 1 then
                    row:SetPoint("TOPLEFT", self.uiFrame.containerScrollFrame, 20, -20)
                else
                    row:SetPoint("BOTTOM", self.uiFrame.containerScrollFrame.rows[i-1], 0, -45)
                end
                for num = 1, MAX_COLUMNS do
                    local button = self.uiFrame.containerScrollFrame.rows[i]["button"..num]
                    local function SetButton(button)
                        _G[button:GetName().."IconTexture"]:SetSize(ROW_HEIGHT,ROW_HEIGHT)
                        _G[button:GetName().."IconTexture"]:SetAllPoints(button)
                        SetItemButtonTexture(button, button.itemTexture)
                        SetItemButtonQuality(button, button.quality)
                        SetItemButtonCount(button, button.count)
                    end
                    if num == 1 then
                        button:SetPoint("LEFT", row, 0, 0)
                    else
                        button:SetPoint("LEFT", self.uiFrame.containerScrollFrame.rows[i]["button"..num-1], "RIGHT", 10, 0)
                    end
                    button:Show()
                    button.itemTexture, button.count, button.quality, button.itemLink = EMPTY_SLOT, nil, nil, nil
                    SetButton(button)
                    if not currentDB[value][num] then
                        button:Hide()
                    elseif currentDB[value][num] ~= "EmptySlot" then
                        local item = Item:CreateFromID(currentDB[value][num][1])
                        local itemData = {self:GetItemInfo(currentDB[value][num][1])}
                            button.itemLink, button.itemTexture, button.quality = itemData[2], itemData[10], itemData[3]
                            button.count = currentDB[value][num][2]
                            SetButton(button)
                        if not item:GetInfo() then
                            item:ContinueOnLoad(function()
                                itemData = {self:GetItemInfo(currentDB[value][num][1])}
                                button.itemLink = itemData[2]
                                SetButton(button)
                            end)
                        end
                    end
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
    self.uiFrame.containerScrollFrame.scrollBar:SetScript("OnShow", function()
		self:ContainerScrollFrameUpdate()
	end)

	local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Frame", "$parentRow"..i, self.uiFrame.containerScrollFrame)
        row:SetSize(ROW_HEIGHT * MAX_COLUMNS + 0.5, ROW_HEIGHT)
		for num = 1, MAX_COLUMNS do
            row["button"..num] = CreateFrame("Button", "$parentButton"..num, row , "ItemButtonTemplate")
            row["button"..num]:SetSize(ROW_HEIGHT, ROW_HEIGHT)
            row["button"..num]:SetScript("OnEnter", function(button) self:ItemTemplate_OnEnter(button) end)
            row["button"..num]:SetScript("OnLeave", self.ItemTemplate_OnLeave)
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
        if tab == "containersTab" then
            tinsert(tabInfo, {name = "Bags", icon = BAG_TEXTURE})
            tinsert(tabInfo,{name = "Bank", icon = BANK_BUTTON})
            db = self.personalBanksDB[self.selectedCharacter]
        elseif tab == "realmBankTab" then
            db = self.realmBanksDB["RealmBank"]
        elseif tab == "guildBankTab" then
            db = self.guildBanksDB[self.selectedGuild]
        end
        if not db then return end
        for _, bag in ipairs(db) do
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
        for i = 1, 8 do
            local button = self.uiFrame.tabSelectionFrame.buttons[i]
            button:Hide()
            button:SetChecked(false)
            button:Enable()
            if containerInfo and containerInfo[i] then
                button.icon:SetTexture(containerInfo[i].icon)
                button.Text:SetText(containerInfo[i].name)
                button.tooltipText = containerInfo[i].name
                button:Show()
                button.count = i
                button:SetScript("OnClick", function()
                    self.selectedBag[self.selectedTab] = button.count
                    self:UpdateTabButtons()
                    self:SetScrollFrame()
                end)
                if self.selectedBag[self.selectedTab] == i then
                    button:SetChecked(true)
                end
            end

        end

    end

end

AG:ContainersTabsCreate()