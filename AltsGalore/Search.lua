local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local LIMEGREEN = "|cFF32CD32"
local ORANGE= "|cFFFFA500"
local AQUA  = "|cFF00FFFF"
local GREEN  = "|cff00ff00"

function AG:Search()

end

AG.SearchResults = {}

function AG:ProcessItem(data)
    if not data then return end
    local itemID = data[1]
    if itemID then
        local item = Item:CreateFromID(itemID)
        local function nextItem(itemID, data)
            local itemData = {GetItemInfo(itemID)}
            if string.find(string.lower(itemData[1]), string.lower(self.uiFrame.searchbox:GetText())) then
                tinsert(self.SearchResults, {data, itemData})
            end
            self:SearchScrollFrameUpdate()
        end
            if not item:GetInfo() then
                item:ContinueOnLoad(function()
                    nextItem(itemID, data)
                end)
            else
                nextItem(itemID, data)
            end
    end
end

local itemList = {}
local combindedList = {}

function AG:FullSearch()
    wipe(self.SearchResults)
    self.SearchResults = {}

    wipe(itemList)
    itemList = {Container = {}, RealmBank = {}, GuildBank = {}}
    for name, charDB in pairs(self.containersDB) do
        for bagNum, bag in pairs(charDB) do
            for _, slot in pairs(bag) do
                if type(slot) == "table" then
                    itemList.Container[slot[1]] = itemList.Container[slot[1]] or {}
                    itemList.Container[slot[1]][name] = itemList.Container[slot[1]][name] or {}
                    if bagNum <= 5 then
                        itemList.Container[slot[1]][name][1] = itemList.Container[slot[1]][name][1] or {}
                        local currentBag = itemList.Container[slot[1]][name][1]
                        currentBag[1] = currentBag[1] and currentBag[1] + slot[2] or slot[2]
                        currentBag[2] = "Bags"
                    else
                        itemList.Container[slot[1]][name][2] = itemList.Container[slot[1]][name][2] or {}
                        local currentBag = itemList.Container[slot[1]][name][2]
                        currentBag[1] = currentBag[1] and currentBag[1] + slot[2] or slot[2]
                        currentBag[2] = "Bank"
                    end
                end
            end
        end
    end
    if self.personalBanksDB then
        for name, charDB in pairs(self.personalBanksDB) do
            for bagNum, bag in pairs(charDB) do
                for _, slot in pairs(bag) do
                    if type(slot) == "table" then
                        itemList.Container[slot[1]] = itemList.Container[slot[1]] or {}
                        itemList.Container[slot[1]][name] = itemList.Container[slot[1]][name] or {}
                        itemList.Container[slot[1]][name][bagNum+2] = itemList.Container[slot[1]][name][bagNum+2] or {}
                        local currentBag = itemList.Container[slot[1]][name][bagNum+2]
                        currentBag[1] = currentBag[1] and currentBag[1] + slot[2] or slot[2]
                        currentBag[2] = bag.name
                        currentBag[3] = "Personal Bank"
                    end
                end
            end
        end
    end
    if self.realmBanksDB then
        for name, charDB in pairs(self.realmBanksDB) do
            for bagNum, bag in pairs(charDB) do
                for _, slot in pairs(bag) do
                    if type(slot) == "table" then
                        itemList.RealmBank[slot[1]] = itemList.RealmBank[slot[1]] or {}
                        itemList.RealmBank[slot[1]][name] = itemList.RealmBank[slot[1]][name] or {}
                        itemList.RealmBank[slot[1]][name][bagNum] = itemList.RealmBank[slot[1]][name][bagNum] or {}
                        local currentBag = itemList.RealmBank[slot[1]][name][bagNum]
                        currentBag[1] = currentBag[1] and currentBag[1] + slot[2] or slot[2]
                        currentBag[2] = bag.name
                        currentBag[3] = "Realm Bank"
                    end
                end
            end
        end
    end
    if self.guildBanksDB then
        for name, charDB in pairs(self.guildBanksDB) do
            for bagNum, bag in pairs(charDB) do
                for _, slot in pairs(bag) do
                    if type(slot) == "table" then
                        itemList.GuildBank[slot[1]] = itemList.GuildBank[slot[1]] or {}
                        itemList.GuildBank[slot[1]][name] = itemList.GuildBank[slot[1]][name] or {}
                        itemList.GuildBank[slot[1]][name][bagNum] = itemList.GuildBank[slot[1]][name][bagNum] or {}
                        local currentBag = itemList.GuildBank[slot[1]][name][bagNum]
                        currentBag[1] = currentBag[1] and currentBag[1] + slot[2] or slot[2]
                        currentBag[2] = bag.name
                        currentBag[3] = "Guild Bank"
                    end
                end
            end
        end
    end
    wipe(combindedList)
    combindedList = {}
    for _, v in pairs(itemList) do
        for itemID, char in pairs(v) do
            for name, bag in pairs(char) do
                local countText
                local countTextL2
                local totalCount = 0
                local totalGbCount
                local text = ""
                for _, data in pairs (bag) do
                    if data[3] then
                        countTextL2 = countTextL2 and countTextL2 .. WHITE .. " | " .. data[2]..": " .. GREEN .. data[1] or AQUA .."Tabs " .. WHITE .. "- "..data[2]..": " .. GREEN .. data[1]
                        totalGbCount = totalGbCount and totalGbCount + data[1] or data[1]
                        text = WHITE..data[3]..": "
                    else
                        countText = countText and countText..WHITE.." | "..data[2]..": "..GREEN..data[1] or WHITE..data[2]..": "..GREEN..data[1]
                    end

                    totalCount = totalCount + data[1]
                end
                text = countText and totalGbCount and countText.." | "..text..GREEN..totalGbCount or totalGbCount and text..GREEN..totalGbCount or countText
                tinsert(combindedList, {{itemID, name, text, totalCount, countTextL2}})
            end
        end
    end
    -- rate limit tied to half the current frame rate
    local maxDuration = 500/GetFramerate()
    local startTime = debugprofilestop()
    local function continue()
        startTime = debugprofilestop()
        local task = tremove(combindedList)
        while (task) do
            self:ProcessItem(task[1])
            if (debugprofilestop() - startTime > maxDuration) then
                Timer.After(0, continue)
                return
            end
            task = tremove(combindedList)
        end
    end

    return continue()
end


function AG:CreateSearchFrame()
-------------------Search Scroll Frame-------------------
local ROW_HEIGHT = 36   -- How tall is each row?
local MAX_ROWS = 11      -- How many rows can be shown at once?


	self.uiFrame.SearchScrollFrame = CreateFrame("Frame", "AltsGaloreSearchScrollFrame", self.uiFrame.searchTab)
	self.uiFrame.SearchScrollFrame:EnableMouse(true)
	self.uiFrame.SearchScrollFrame:SetSize(800, (ROW_HEIGHT + 12) * (MAX_ROWS) + 24)
    self.uiFrame.SearchScrollFrame:SetPoint("BOTTOMRIGHT", self.uiFrame.searchTab, -16, 16)
	self.uiFrame.SearchScrollFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	self.uiFrame.SearchScrollFrame.lable = self.uiFrame.SearchScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.SearchScrollFrame.lable:SetJustifyH("LEFT")
	self.uiFrame.SearchScrollFrame.lable:SetPoint("TOPLEFT", self.uiFrame.SearchScrollFrame, 66, -15)
    self.uiFrame.SearchScrollFrame.lable:SetFont("Fonts\\FRIZQT__.TTF", 15)
	self.uiFrame.SearchScrollFrame.lable:SetText("Item / Item Type")
    self.uiFrame.SearchScrollFrame.lable2 = self.uiFrame.SearchScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.SearchScrollFrame.lable2:SetJustifyH("LEFT")
	self.uiFrame.SearchScrollFrame.lable2:SetPoint("LEFT", self.uiFrame.SearchScrollFrame.lable, "RIGHT", 95, 0)
	self.uiFrame.SearchScrollFrame.lable2:SetText("Character")
    self.uiFrame.SearchScrollFrame.lable2:SetFont("Fonts\\FRIZQT__.TTF", 15)
    self.uiFrame.SearchScrollFrame.lable3 = self.uiFrame.SearchScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.SearchScrollFrame.lable3:SetJustifyH("LEFT")
	self.uiFrame.SearchScrollFrame.lable3:SetPoint("LEFT", self.uiFrame.SearchScrollFrame.lable2, "RIGHT", 88, 0)
	self.uiFrame.SearchScrollFrame.lable3:SetText("Location")
    self.uiFrame.SearchScrollFrame.lable3:SetFont("Fonts\\FRIZQT__.TTF", 15)

	function AG:SearchScrollFrameUpdate()
        if not self.SearchResults then return end
		local maxValue = #self.SearchResults
		FauxScrollFrame_Update(self.uiFrame.SearchScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(self.uiFrame.SearchScrollFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
            local row = self.uiFrame.SearchScrollFrame.rows[i]
			if value <= maxValue then
                if i == 1 then
                    row:SetPoint("TOPLEFT", self.uiFrame.SearchScrollFrame, 20, -44)
                else
                    row:SetPoint("BOTTOM", self.uiFrame.SearchScrollFrame.rows[i-1], 0, -45)
                end
                    local function SetButton()
                        _G[row:GetName().."IconTexture"]:SetSize(ROW_HEIGHT,ROW_HEIGHT)
                        _G[row:GetName().."IconTexture"]:SetAllPoints(row)
                        SetItemButtonTexture(row, row.itemTexture)
                        SetItemButtonQuality(row, row.quality)
                        SetItemButtonCount(row, row.count)
                    end
                    if not self.SearchResults[value] then
                        row:Hide()
                    else
                        local itemData = self.SearchResults[value][2]
                        local _, name, container, total, containerL2 = unpack(self.SearchResults[value][1])
                        row.itemLink, row.itemTexture, row.quality = itemData[2], itemData[10], itemData[3]
                        row.count = total
                        row[1].Text:SetText(select(4,GetItemQualityColor(row.quality))..itemData[1])
                        row[2].Text:SetText(AG:FixText(itemData[9]..", ".. itemData[7]))
                        row[3].Text:SetText(GREEN .. name)
                        row[4].Text:SetText(container)
                        row[5].Text:SetText(containerL2)
                        SetButton()
                    end
				row:Show()
            else
                row:Hide()
			end
		end
	end

	self.uiFrame.SearchScrollFrame.scrollBar = CreateFrame("ScrollFrame", "AltsGaloreSearchScrollFrameScrollBar", self.uiFrame.SearchScrollFrame, "FauxScrollFrameTemplate")
	self.uiFrame.SearchScrollFrame.scrollBar:SetPoint("TOPLEFT", 0, -8)
	self.uiFrame.SearchScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -30, 8)
	self.uiFrame.SearchScrollFrame.scrollBar:SetScript("OnVerticalScroll", function(scroll, offset)
		scroll.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		self:SearchScrollFrameUpdate()
	end)
    local function CreateRow(row, i)
        row[i] = CreateFrame("Button", "$parentText"..i, row)
        if i == 1 then
            row[i]:SetPoint("TOPLEFT", row, "RIGHT", 0, 10)
        else
            row[i]:SetPoint("TOPLEFT", row[i-1], "RIGHT", 0, 10)
        end
        row[i].Text = row[i]:CreateFontString(nil , "OVERLAY", "GameFontNormal")
        row[i].Text:SetJustifyH("LEFT")
        row[i].Text:SetPoint("LEFT")
        row[i]:SetScript("OnShow", function() row[i].Text:SetSize(row[i]:GetWidth()-5, 12) end)
    end

	local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Button", "$parentRow"..i, self.uiFrame.SearchScrollFrame , "ItemButtonTemplate")
            row:SetSize(ROW_HEIGHT + 0.5, ROW_HEIGHT)
            row:SetScript("OnEnter", function(button) self:ItemTemplate_OnEnter(button) end)
            row:SetScript("OnLeave", self.ItemTemplate_OnLeave)
            for num = 1, 5 do
                CreateRow(row, num)
                row[num]:ClearAllPoints()
            end

            row[1]:SetSize(200, 22)
            row[1]:SetPoint("TOPLEFT", row, "TOPRIGHT", 10, 2)
            row[2]:SetSize(200, 14)
            row[2]:SetPoint("CENTER", row[1], "BOTTOM", 0, -7)
            row[3]:SetSize(150, 18)
            row[3]:SetPoint("LEFT", row[1], "RIGHT", 0, 0)
            row[4]:SetSize(400, 18)
            row[4]:SetPoint("LEFT", row[3], "RIGHT", 0, 0)
            row[5]:SetSize(400, 18)
            row[5]:SetPoint("CENTER", row[4], "BOTTOM", 0, -7)

		rawset(t, i, row)
		return row
	end })

	self.uiFrame.SearchScrollFrame.rows = rows

end

AG:CreateSearchFrame()

function AG:FixText(text)
    if not string.find(string.lower(text), string.lower("INVTYPE")) then
        text = gsub(text, ", Leather", "Leather")
        text = gsub(text, ", Cloth", "Cloth")
    end
     -- Body Slot
     text = gsub(text, "INVTYPE_HEAD", "Head")
     text = gsub(text, "INVTYPE_NECK, Miscellaneous", "Neck")
     text = gsub(text, "INVTYPE_SHOULDER", "Shoulder")
     text = gsub(text, "INVTYPE_CLOAK, Cloth", "Back")
     text = gsub(text, "INVTYPE_CHEST", "Chest")
     text = gsub(text, "INVTYPE_BODY", "Shirt")
     text = gsub(text, "INVTYPE_ROBE", "Chest")
     text = gsub(text, "INVTYPE_TABARD, Miscellaneous", "Tabard")
     text = gsub(text, "INVTYPE_WRIST", "Wrist")
     text = gsub(text, "INVTYPE_HAND", "Hands")
     text = gsub(text, "INVTYPE_WAIST", "Waist")
     text = gsub(text, "INVTYPE_LEGS", "Legs")
     text = gsub(text, "INVTYPE_FEET", "Feet")
     text = gsub(text, "INVTYPE_FINGER, Miscellaneous", "Ring")
     text = gsub(text, "INVTYPE_TRINKET, Miscellaneous", "Trinket")
     text = gsub(text, "INVTYPE_RELIC, Miscellaneous", "Relic")
 
     -- Weapon Weilding
     text = gsub(text, "INVTYPE_WEAPON, ", "")
     text = gsub(text, "INVTYPE_2HWEAPON, ", "")
     text = gsub(text, "INVTYPE_WEAPONMAINHAND, ", "")
     text = gsub(text, "INVTYPE_WEAPONOFFHAND, ", "")
     text = gsub(text, "INVTYPE_RANGED, ", "")
     text = gsub(text, "INVTYPE_SHIELD, ", "")
     text = gsub(text, "INVTYPE_HOLDABLE, Miscellaneous", "Off Hand")
     text = gsub(text, "INVTYPE_THROWN, ", "") 
 
     -- Weapon Type
     text = gsub(text, "Axes", "Axe")
     text = gsub(text, "Bows", "Bow")
     text = gsub(text, "INVTYPE_RANGEDRIGHT, Crossbows", "Crossbow")
     text = gsub(text, "INVTYPE_RANGEDRIGHT, Gun", "Gun")
     text = gsub(text, "Daggers", "Dagger")
     text = gsub(text, "Guns", "Gun")
     text = gsub(text, "INVTYPE_AMMO, Bullet", "Bullet")
     text = gsub(text, "INVTYPE_AMMO, Arrow", "Arrow")
     text = gsub(text, "One%-Handed Maces", "One-Handed Mace")
     text = gsub(text, "Two%-Handed Maces", "Two-Handed Mace")
     text = gsub(text, "Polearms", "Polearm")
     text = gsub(text, "Shields", "Shield")
     text = gsub(text, "Staves", "Staff")
     text = gsub(text, "One%-Handed Swords", "One-Handed Sword")
     text = gsub(text, "Two%-Handed Swords", "Two-Handed Sword")
     text = gsub(text, "INVTYPE_RANGEDRIGHT, Wands", "Wand")
     text = gsub(text, "Fist Weapons", "Fist Weapon")
     text = gsub(text, "INVTYPE_RELIC, Idols", "Idol")
     text = gsub(text, "INVTYPE_RELIC, Totem", "Totem")
     text = gsub(text, "INVTYPE_RELIC, Libram", "Libram")
     text = gsub(text, "INVTYPE_BAG, Bag", "Bag")
     text = gsub(text, "INVTYPE_BAG, Soul Bag", "Soul Bag")
     text = gsub(text, "#w21#", "Sigil")

     text = gsub(text, ", Pet", "Pet")
     text = gsub(text, ", Money", "Currency")
     text = gsub(text, ", Consumable", "Consumable")
     text = gsub(text, ", Mount", "Mount")
     text = gsub(text, ", Quest", "Quest")
     text = gsub(text, ", Key", "Key")
     text = gsub(text, ", Book", "Book")
     text = gsub(text, ", Materials", "Reagent")
     text = gsub(text, ", Flask", "Flask")
     text = gsub(text, ", Other", "Misc")
     text = gsub(text, ", Junk", "Misc")
     text = gsub(text, "%(OBSOLETE%)", "")
     text = gsub(text, ", Food & Drink", "Food & Drink")
     text = gsub(text, ", Parts", "Engineering Parts")

     text = gsub(text, ", Red", "Red Gem")
     text = gsub(text, ", Blue", "Blue Gem")
     text = gsub(text, ", Yellow", "Yellow Gem")
     text = gsub(text, ", Purple", "Purple Gem")
     text = gsub(text, ", Orange", "Orange Gem")
     text = gsub(text, ", Green", "Green Gem")

     text = gsub(text, ", Jewelcrafting", "Jewelcrafting")
     text = gsub(text, ", Enchanting", "Enchanting")
     text = gsub(text, ", Tailoring", "Tailoring")
     text = gsub(text, ", Blacksmithing", "Blacksmithing")
     text = gsub(text, ", Leatherworking", "Leatherworking")
     text = gsub(text, ", Alchemy", "Alchemy")
     text = gsub(text, ", Engineering", "Engineering")
     text = gsub(text, ", Cooking", "Cooking")
     text = gsub(text, ", Mining", "Mining")
     text = gsub(text, ", Herbalism", "Herbalism")
     text = gsub(text, ", Herb", "Herbalism")
     text = gsub(text, ", Meat", "Meat")
     text = gsub(text, ", Item Enhancement", "Enchant")
     text = gsub(text, ", Weapon Enchantment", "Enchanting")
     text = gsub(text, ", Armor Enchantment", "Enchanting")
     text = gsub(text, ", Scroll", "Scroll")
     text = gsub(text, ", Holiday", "Holiday")
     text = gsub(text, ", Metal & Stone", "Metal & Stone")
     text = gsub(text, ", Potion", "Potion")
     text = gsub(text, ", Engineering", "Parts")
     text = gsub(text, ", Simple", "Gems")
     text = gsub(text, ", Elemental", "Elemental")
     text = gsub(text, ", Elixir", "Elixir")
     text = gsub(text, ", Reagent", "Reagent")
     text = gsub(text, ", Devices", "Devices")
     text = gsub(text, ", Trade Goods", "Trade Goods")
     return text
end