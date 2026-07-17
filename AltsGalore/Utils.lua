local Utils = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local LIMEGREEN = "|cFF32CD32"
local ORANGE= "|cFFFFA500"
local AQUA  = "|cFF00FFFF"
local GREEN  = "|cff00ff00"

local cTip = CreateFrame("GameTooltip","cTooltip",nil,"GameTooltipTemplate")

function Utils:IsRealmbound(bag, slot)
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

function Utils:GetClassColor(classFilename)
	local color = RAID_CLASS_COLORS[classFilename];
	if color then
        return ""
		--return format("|c%.2x%.2x%.2x%.2x", 0, color.r, color.g, color.b)
	end
end

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
function Utils:HasItem(itemID)
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

function Utils:ItemTemplate_OnEnter(button)
    self.shiftKeyDown = false
    if not button.itemLink then return end
    if IsShiftKeyDown() then
        self.shiftKeyDown = true
    end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT", -13, -50)
    GameTooltip:SetHyperlink(button.itemLink)
    GameTooltip:Show()
end

function Utils:ItemTemplate_OnLeave()
    self.shiftKeyDown = false
    GameTooltip:Hide()
end

function Utils:GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function Utils:OnEnter(button, show)
    if self.db.autoMenu and not UnitAffectingCombat("player") then
        --self:DewdropRegister(button, show)
    else
        GameTooltip:SetOwner(button, 'ANCHOR_NONE')
        GameTooltip:SetPoint(self:GetTipAnchor(button))
        GameTooltip:ClearLines()
        GameTooltip:AddLine("AltsGalore")
        GameTooltip:Show()
    end
end

function Utils:PairsByKeys(t, reverse)
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

function Utils:SetTooltipText(button, text)
    GameTooltip:SetOwner(button, 'ANCHOR_NONE')
    GameTooltip:SetPoint(self:GetTipAnchor(button))
    GameTooltip:ClearLines()
    GameTooltip:AddLine(text)
    GameTooltip:Show()
end

local realmWideCurrencyIDs = {
        [90004] = true,     -- Token of Prestige
        [98463] = true,     -- Mystic Extracts
        [97397] = true,     -- Seasonal Points
        [1008000] = true,   -- Season's Achievement
        [1297307] = true,   -- Bedlam Bullion
        [1297308] = true,   -- Bonzo Bolts
}

function Utils:UpdateCurrencyDB()
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

function Utils:CURRENCY_DISPLAY_UPDATE()
    self:UpdateCurrencyDB()
end

function Utils:MERCHANT_UPDATE()
    self:UpdateCurrencyDB()
end

function Utils:PLAYER_MONEY()

end

local itemEquipLocConversion = {
	"INVTYPE_HEAD","INVTYPE_NECK","INVTYPE_SHOULDER","INVTYPE_BODY","INVTYPE_CHEST",
	"INVTYPE_WAIST","INVTYPE_LEGS","INVTYPE_FEET","INVTYPE_WRIST",	"INVTYPE_HAND",
	"INVTYPE_FINGER","INVTYPE_TRINKET","INVTYPE_WEAPON","INVTYPE_SHIELD","INVTYPE_RANGED",
	"INVTYPE_CLOAK","INVTYPE_2HWEAPON","INVTYPE_BAG","INVTYPE_TABARD","INVTYPE_ROBE",
    "INVTYPE_WEAPONMAINHAND","INVTYPE_WEAPONOFFHAND","INVTYPE_HOLDABLE","INVTYPE_AMMO",
    "INVTYPE_THROWN","INVTYPE_RANGEDRIGHT","INVTYPE_QUIVER","INVTYPE_RELIC",
}
function Utils:GetItemInfo(item)
	item = tonumber(item) and Item:CreateFromID(item) or Item:CreateFromLink(item)
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(item.itemID)
	if not item:GetInfo() then
		local itemInstant = GetItemInfoInstant(item.itemID)
		if itemInstant then
			itemName = itemInstant.name
			itemSubType = _G["ITEM_SUBCLASS_"..itemInstant.classID.."_"..itemInstant.subclassID]
			itemEquipLoc = itemEquipLocConversion[itemInstant.inventoryType]
			itemTexture = itemInstant.icon
			itemQuality = itemInstant.quality
			itemLink = item:GetLink()
		end
	end
	return itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice
end

--------------------------------- DewDrop Dropdownmenu ---------------------------------
-- Used to create a dewdrop menus from tables
function Utils:OpenDewdropMenu(frame, menuList, ...)
	if self.Dewdrop:IsOpen(frame) then self.Dewdrop:Close() return end
	local textSize = AtlasLoot.selectedProfile.txtSize or 12
	local menuTables = {...}
	if #menuTables > 0 then
		-- if more then 1 table is sent combine them into 1 table
		for _, v in pairs(menuTables) do
			for level, list in pairs(v) do
				for _, entry in pairs(list) do
					menuList[level] = menuList[level] or {}
						table.insert(menuList[level], entry)
				end
			end
		end
	end

	local function addDiviver(maxLenght)
		local text = self.Colors.WHITE.."----------------------------------------------------------------------------------------------------"
		self.Dewdrop:AddLine(
			"text" , text:sub(1, maxLenght),
			"textHeight", textSize,
			"textWidth", textSize,
			"isTitle", true,
			"notCheckable", true
		)
	end
	self.Dewdrop:Open(frame,
		"point", function(parent)
			local point1, _, point2 = self:GetTipAnchor(frame)
    		return point1, point2
		end,
		"children", function(level, value)
			local textLength = menuList.dividerLength or 35
			for i, menu in pairs(menuList[level]) do
				if menu.showOnCondition == nil or menu.showOnCondition == true then
					if menu.show == nil or value == menu.show then
						if menu.divider then
							addDiviver(textLength)
						end
						local checked = menu.checked
						if menu.checked and type(menu.checked) == "table" then
							checked = menu.checked[1][menu.checked[2]]
						end
						local text = menu.isTitle and self.Colors.YELLOW..menu.text or menu.text
						self.Dewdrop:AddLine(
							"text", text,
							"isTitle", menu.isTitle,
							"value", menu.value,
							"hasArrow", menu.hasArrow,
							"closeWhenClicked", not menu.dontCloseWhenClicked,
							"textHeight", menu.textHeight or textSize,
							"textWidth", menu.textWidth or textSize,
							"checked", checked,
							"notCheckable", (checked == nil or not menu.isRadio),
							"tooltip", menu.tooltip or menu.text,
							"secure", menu.secure,
							"icon", menu.icon,
							"isRadio", menu.isRadio,
							"func", menu.func
						)
					end
				end
				-- create close button
				if i == #menuList[level] then
					addDiviver(textLength)
					self.Dewdrop:AddLine(
						"text", self.Colors.CYAN..AL["Close Menu"],
						"textHeight", textSize,
						"textWidth", textSize,
						"closeWhenClicked", true,
						"notCheckable", true
					)
				end
			end
		end
	)
end

-------------------------------------------------------------------------------