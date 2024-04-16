local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")

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

function AG:ScanContainer(bagID)
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
    if self.uiFrame.containerScrollFrame:IsVisible() then
        self:SetScrollFrame()
    end
end

function AG:GUILDBANKBAGSLOTS_CHANGED()
    if not GuildBankFrame then return end
    local gBankType, containerType
    if GuildBankFrame.IsPersonalBank then
        gBankType = "personalBanksDB"
        containerType = self.thisChar
    elseif GuildBankFrame.IsRealmBank then
        gBankType = "realmBanksDB"
        containerType = "RealmBank"
    elseif self.guild then
        gBankType = "guildBanksDB"
        containerType = self.guild
    end

    local db = self[gBankType][containerType]
    local tab = GetCurrentGuildBankTab()
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
    if self.uiFrame.containerScrollFrame:IsVisible() then
        self:SetScrollFrame()
    end
end