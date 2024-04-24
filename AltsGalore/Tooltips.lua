local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local LIMEGREEN = "|cFF32CD32"
local ORANGE= "|cFFFFA500"
local AQUA  = "|cFF00FFFF"
local GREEN  = "|cff00ff00"
local headerSet
local function SetHeader(tooltip)
    if headerSet then return true end
    GameTooltip:AddLine(tooltip)
    return true
end
local function SetTooltip(itemID, headerTooltip)
    local self = AG
    local addLine
    local needSort = {}
    headerSet = false
    for name, char in pairs(self.realmDB) do
        if name ~= "currency" then
            for _, currency in pairs(char.currency) do
                if type(currency) == "table" and not currency.realmWide and itemID == currency[3] then
                    needSort[currency[2]] = name
                end
            end
        end
    end
    for currency, name in AG:PairsByKeys(needSort, true) do
        GameTooltip:AddDoubleLine(GREEN..name, WHITE.."(Currency: "..GREEN..currency..WHITE..")")
        addLine = true
    end
    if addLine then
        GameTooltip:AddLine(" ")
        return
    end

    --create list of characters that have the item in there bag/bank to be shown on the items tooltip
    local totalOwned = 0
    local charList = {}
    for name, bags in pairs(self.containersDB) do
        if not charList[name] then charList[name] = {} end
        for i, bag in pairs(bags) do
            if (i >= 1) and (i <= 5) then
                for _, slot in pairs(bag) do
                    if type(slot) == "table" and slot[1] == itemID then
                        charList[name].Bags = charList[name].Bags and charList[name].Bags + slot[2] or slot[2]
                    end
                end
            else
                for _, slot in pairs(bag) do
                    if type(slot) == "table" and slot[1] == itemID then
                        charList[name].Bank = charList[name].Bank and charList[name].Bank + slot[2] or slot[2]
                    end
                end
            end
        end
    end
    --add characters personal bank to list if it has the item
    local personalBank = {}
    for name, bags in pairs(self.personalBanksDB) do
        personalBank[name] = personalBank[name] or {}
        for i, bag in pairs(bags) do
            for _, slot in pairs(bag) do
                if type(slot) == "table" and slot[1] == itemID then
                    personalBank[name][i] = personalBank[name][i] or {name = bag.name}
                    personalBank[name][i].count = personalBank[name][i].count and personalBank[name][i].count + slot[2] or slot[2]
                end
            end
            if personalBank[name][i] then
                personalBank[name].total = personalBank[name].total and personalBank[name].total + personalBank[name][i].count or personalBank[name][i].count
            end

        end
    end
    GameTooltip:AddLine(" ")

    --creates the character tooltip from data thats just been processed
    for name, char in pairs(charList) do
        local cList = ""
        local total = 0
        if char.Bags then
            total = total + char.Bags
            cList =  WHITE.."(Bags: "..GREEN..char.Bags..WHITE..") "
        end
        if char.Bank then
            total = total + char.Bank
            cList =  cList..WHITE.."(Bank: "..GREEN..char.Bank..WHITE..") "
        end
        if personalBank[name] and personalBank[name].total then
            local tooltip
            if IsShiftKeyDown() or self.detailedGuildBankCount or self.shiftKeyDown then
                
                for _, bag in pairs(personalBank[name]) do
                    if type(bag) == "table" then
                        local text = WHITE.."("..bag.name..": "..GREEN..bag.count..WHITE..") "
                        tooltip = tooltip and tooltip .. text or text
                    end
                end
                cList = cList..tooltip
            else
                cList = cList..WHITE.."(Personal Bank: "..GREEN..personalBank[name].total..WHITE..") "
            end
            total = total + personalBank[name].total
        end

        if total ~= 0 then
            headerSet = SetHeader(headerTooltip)
            totalOwned = totalOwned + total
            GameTooltip:AddDoubleLine(GREEN..name, (ORANGE..total.." ")..cList)
        end
    end
    --creates the realm bank data and tooltip
    local realmBank = {}
    for i, bag in pairs(self.realmBanksDB.RealmBank) do
        for _, slot in pairs(bag) do
            if type(slot) == "table" and slot[1] == itemID then
                realmBank[i] = realmBank[i] or {name = bag.name}
                realmBank[i].count = realmBank[i].count and realmBank[i].count + slot[2] or slot[2]
            end
        end
        if realmBank[i] then
            realmBank.total = realmBank.total and realmBank.total + realmBank[i].count or realmBank[i].count
        end
    end
    if realmBank and realmBank.total then
        local tooltip
        if IsShiftKeyDown() or self.detailedGuildBankCount or self.shiftKeyDown then
            for _, v in pairs(realmBank) do
                if type(v) == "table" then
                    local text = WHITE.."("..v.name..": "..GREEN..v.count..WHITE..") "
                    tooltip = tooltip and tooltip .. text or text
                end
            end
            tooltip = ORANGE..realmBank.total..tooltip
        else
            tooltip = WHITE.."(Realm Bank: "..GREEN..realmBank.total..WHITE..")"
        end
        headerSet = SetHeader(headerTooltip)
        GameTooltip:AddDoubleLine(CYAN.."Realm Bank", tooltip)
        totalOwned = totalOwned + realmBank.total
    end
    --creates the guild bank data and tooltip
    local guildBank = {}
    for name, bags in pairs(self.guildBanksDB) do
        guildBank[name] = {}
        for i, bag in pairs(bags) do
            for _, slot in pairs(bag) do
                if type(slot) == "table" and slot[1] == itemID then
                    guildBank[name][i] = guildBank[name][i] or {name = bag.name}
                    guildBank[name][i].count = guildBank[name][i].count and guildBank[name][i].count + slot[2] or slot[2]
                end
            end
            if guildBank[name][i] then
                guildBank[name].total = guildBank[name].total and guildBank[name].total + guildBank[name][i].count or guildBank[name][i].count
            end

        end
        if guildBank[name] and guildBank[name].total then
            local tooltip
            if IsShiftKeyDown() or self.detailedGuildBankCount or self.shiftKeyDown then
                for _, v in pairs(guildBank[name]) do
                    if type(v) == "table" then
                        local text = WHITE.."("..v.name..": "..GREEN..v.count..WHITE..")"
                        tooltip = tooltip and tooltip .. text or text
                    end
                end
                tooltip = ORANGE..guildBank[name].total..tooltip
            else
                tooltip = WHITE.."(Guild Bank: "..GREEN..guildBank[name].total..WHITE..")"
            end
            headerSet = SetHeader(headerTooltip)
            GameTooltip:AddDoubleLine(ORANGE..name, tooltip)
            if not bags.hideInTotal then
                totalOwned = totalOwned + guildBank[name].total
            end
        end
    end

    if totalOwned ~= 0 then
        GameTooltip:AddLine("Total Owned: "..GREEN..totalOwned)
    end
end

local function TooltipHandlerItem(tooltip)
    --checks for combat less likley to cause a lag spike
    if UnitAffectingCombat("player") then return end
    --get item link and itemID
	local link = select(2, tooltip:GetItem())
	if not link then return end
	local itemID = GetItemInfoFromHyperlink(link)
	if not itemID then return end
    SetTooltip(itemID)
end

GameTooltip:HookScript("OnTooltipSetItem", TooltipHandlerItem)

-- All types, primarily for detached tooltips
local function onSetHyperlink(self, link)
    if UnitAffectingCombat("player") then return end
    local type, id = string.match(link,"^(%a+):(%d+)")
    if not type or not id then return end
    if type == "quest" then
        local quest = GetQuestTemplate(id)
        if quest.RequiredItemId then
            for _, itemID in pairs(quest.RequiredItemId) do
                if itemID and itemID ~= 0 then
                    SetTooltip(itemID, select(2,GetItemInfo(itemID)))
                end
            end
        end
    end
end

hooksecurefunc(ItemRefTooltip, "SetHyperlink", onSetHyperlink)
hooksecurefunc(GameTooltip, "SetHyperlink", onSetHyperlink)