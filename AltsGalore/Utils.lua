local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local LIMEGREEN = "|cFF32CD32"
local ORANGE= "|cFFFFA500"
local AQUA  = "|cFF00FFFF"
local GREEN  = "|cff00ff00"


local cTip = CreateFrame("GameTooltip","cTooltip",nil,"GameTooltipTemplate")

function AG:IsRealmbound(bag, slot)
    cTip:SetOwner(UIParent, "ANCHOR_NONE")
    cTip:SetBagItem(bag, slot)
    cTip:Show()
    for i = 1,cTip:NumLines() do
        local text = _G["cTooltipTextLeft"..i]:GetText()
        if text == "Realm Bound" or text == ITEM_SOULBOUND then
            return true
        end
    end
    cTip:Hide()
    return false
end

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
function AG:HasItem(itemID)
	local item, found, id
	-- scan bags
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			item = GetContainerItemLink(bag, slot)
			if item then
				found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
				if found and tonumber(id) == itemID then
					return true, bag, slot
				end
			end
		end
	end
	return false
end

-- add item or spell to the dropdown menu
function AG:AddEntry(ID, eType)
    if not CA_IsSpellKnown(ID) and not self:HasItem(ID) and not C_VanityCollection.IsCollectionItemOwned(ID) then return end
    local startTime, duration, name, icon

    if eType == "item" then
        name, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)
        startTime, duration = GetItemCooldown(ID)
    else
        name, _, icon = GetSpellInfo(ID)
        startTime, duration = GetSpellCooldown(ID)
    end

	local cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
	local text = name

	if cooldown > 0 then
	text = name.." |cFF00FFFF("..cooldown.." ".. "mins" .. ")"
	end
	local secure = {
	type1 = eType,
	[eType] = name
	}

    AG.dewdrop:AddLine(
            'text', text,
            'icon', icon,
            'secure', secure,
            'func', function()
                if eType == "item" and not self:HasItem(ID) then
                    RequestDeliverVanityCollectionItem(ID)
                else
                    if eType == "item" and self.db.deleteItem then
                        self.deleteItem = ID
                        self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
                    end
                    AG.dewdrop:Close()
                end
            end,
            'textHeight', self.db.txtSize,
            'textWidth', self.db.txtSize
    )
end

--for a adding a divider to dew drop menus 
function AG:AddDividerLine(maxLenght)
    local text = WHITE.."----------------------------------------------------------------------------------------------------"
    AG.dewdrop:AddLine(
        'text' , text:sub(1, maxLenght),
        'textHeight', self.db.txtSize,
        'textWidth', self.db.txtSize,
        'isTitle', true,
        "notCheckable", true
    )
    return true
end

function AG:GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function AG:OnEnter(button, show)
    if self.db.autoMenu and not UnitAffectingCombat("player") then
        self:DewdropRegister(button, show)
    else
        GameTooltip:SetOwner(button, 'ANCHOR_NONE')
        GameTooltip:SetPoint(AG:GetTipAnchor(button))
        GameTooltip:ClearLines()
        GameTooltip:AddLine("AltsGalore")
        GameTooltip:Show()
    end
end

function AG:GetItemIdFromLink(link)
    if not link then return end
    return tonumber(select(3, strfind(link , "^|%x+|Hitem:(%-?%d+).*")))
end

local function TooltipHandlerItem(tooltip)
	local link = select(2, tooltip:GetItem())
	if not link then return end
	local itemID = GetItemInfoFromHyperlink(link)
	if not itemID then return end
    local charList = {}
    for name, bags in pairs(AG.containersDB) do
        if not charList[name] then charList[name] = {} end
        for i, bag in pairs(bags) do
            if (i >= 1) and (i <= 5) then
                for _, slot in pairs(bag) do
                    if slot[1] == itemID then
                        charList[name].Bags = charList[name].Bags and charList[name].Bags + slot[2] or slot[2]
                    end
                end
            else
                for _, slot in pairs(bag) do
                    if slot[1] == itemID then
                        charList[name].Bank = charList[name].Bank and charList[name].Bank + slot[2] or slot[2]
                    end
                end
            end
        end
    end
    for name, bags in pairs(AG.personalBanksDB) do
        for _, bag in pairs(bags) do
            for _, slot in pairs(bag) do
                if slot[1] == itemID then
                    charList[name].PersonalBank = charList[name].PersonalBank and charList[name].PersonalBank + slot[2] or slot[2]
                end
            end
        end
    end
    GameTooltip:AddLine(" ")
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
        if char.PersonalBank then
            total = total + char.PersonalBank
            cList =  cList..WHITE.."(PersonalBank: "..GREEN..char.PersonalBank..WHITE..")"
        end
        if total ~= 0 then
            total = ORANGE..total.." "
            GameTooltip:AddDoubleLine(CYAN..name, total..cList)
        end
    end

    local realmBank
    for _, bag in pairs(AG.realmBanksDB.RealmBank) do
        for _, slot in pairs(bag) do
            if slot[1] == itemID then
                realmBank = realmBank and realmBank + slot[2] or slot[2]
            end
        end
    end
    if realmBank then
        GameTooltip:AddDoubleLine(GREEN.."Realm Bank", WHITE.."(Realm Bank: "..GREEN..realmBank..WHITE..")")
    end

    local guildBank
    for name, bags in pairs(AG.guildBanksDB) do
        guildBank = nil
        for _, bag in pairs(bags) do
            for _, slot in pairs(bag) do
                if slot[1] == itemID then
                    guildBank = guildBank and guildBank + slot[2] or slot[2]
                end
            end
        end
        if guildBank then
            GameTooltip:AddDoubleLine(ORANGE..name, WHITE.."(Guild Bank: "..GREEN..guildBank..WHITE..")")
        end
    end

end

GameTooltip:HookScript("OnTooltipSetItem", TooltipHandlerItem)