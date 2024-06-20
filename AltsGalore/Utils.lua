local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local LIMEGREEN = "|cFF32CD32"
local ORANGE= "|cFFFFA500"
local AQUA  = "|cFF00FFFF"
local GREEN  = "|cff00ff00"


local function GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

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

function AG:ItemTemplate_OnEnter(button)
    self.shiftKeyDown = false
    if not button.itemLink then return end
    if IsShiftKeyDown() then
        self.shiftKeyDown = true
    end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT", -13, -50)
    GameTooltip:SetHyperlink(button.itemLink)
    GameTooltip:Show()
end

function AG:ItemTemplate_OnLeave()
    self.shiftKeyDown = false
    GameTooltip:Hide()
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

function AG:PairsByKeys(t, reverse)
    local function order(a, b)
        if reverse then
            return a > b
        else
            return a<b
        end
    end
    local a = {}
    for n in pairs(t) do
      table.insert(a, n)
    end
    table.sort(a, function(a,b) return order(a,b)  end)

    local i = 0
    local iter = function()
      i = i + 1
      if a[i] == nil then
        return nil
      else
        return a[i], t[a[i]]
      end
    end
    return iter
end

function AG:GetItemIdFromLink(link)
    if not link then return end
    return tonumber(select(3, strfind(link , "^|%x+|Hitem:(%-?%d+).*")))
end

function AG:SetTooltipText(button, text)
    GameTooltip:SetOwner(button, 'ANCHOR_NONE')
    GameTooltip:SetPoint(GetTipAnchor(button))
    GameTooltip:ClearLines()
    GameTooltip:AddLine(text)
    GameTooltip:Show()
end

local realmWideCurrencyIDs = {
        [90004] = true,     -- Token of Prestige
        [98463] = true,     -- Mystic Extracts
        [97397] = true,     -- Seasonal Points
        [1008000] = true,   -- Season's Achievement     
}

function AG:UpdateCurrencyDB()
    if not self.realmDB or not self.charDB then return end

    self.charDB.currency = self.charDB.currency or {}
    self.realmDB.currency = self.realmDB.currency or  {}
    local currencies = self.charDB.currency
    wipe(currencies)

    for i = 1, GetCurrencyListSize() do
        local cInfo = {GetCurrencyListInfo(i)}
        local name, isHeader, count, itemID = cInfo[1], cInfo[2], cInfo[6], cInfo[9]
        name = name or ""
        if isHeader then
            currencies[i] = name
        elseif realmWideCurrencyIDs[itemID] then
            currencies[i] = {realmWide = itemID}
            self.realmDB.currency[itemID] = {name, count}
        else
            currencies[i] = {name, count, itemID}
        end
    end
end

function AG:CURRENCY_DISPLAY_UPDATE()
    AG:UpdateCurrencyDB()
end

function AG:MERCHANT_UPDATE()
    AG:UpdateCurrencyDB()
end

function AG:PLAYER_MONEY()

end

local itemEquipLocConversion = {
	"INVTYPE_HEAD",
	"INVTYPE_NECK",
	"INVTYPE_SHOULDER",
	"INVTYPE_BODY",
	"INVTYPE_CHEST",
	"INVTYPE_WAIST",
	"INVTYPE_LEGS",
	"INVTYPE_FEET",
	"INVTYPE_WRIST",
	"INVTYPE_HAND",
	"INVTYPE_FINGER",
	"INVTYPE_TRINKET",
	"INVTYPE_WEAPON",
	"INVTYPE_SHIELD",
	"INVTYPE_RANGED",
	"INVTYPE_CLOAK",
	"INVTYPE_2HWEAPON",
	"INVTYPE_BAG",
	"INVTYPE_TABARD",
	"INVTYPE_ROBE",
	"INVTYPE_WEAPONMAINHAND",
	"INVTYPE_WEAPONOFFHAND",
	"INVTYPE_HOLDABLE",
	"INVTYPE_AMMO",
	"INVTYPE_THROWN",
	"INVTYPE_RANGEDRIGHT",
	"INVTYPE_QUIVER",
	"INVTYPE_RELIC",
}
function AG:GetItemInfo(itemID)
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemID)
	if not itemName then
		local item = GetItemInfoInstant(itemID)
		itemName, itemSubType, itemEquipLoc, itemTexture, itemQuality = item.name, _G["ITEM_SUBCLASS_"..item.classID.."_"..item.subclassID], itemEquipLocConversion[item.inventoryType], item.icon, item.quality
	end
	return itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice
end