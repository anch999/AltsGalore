local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local LIMEGREEN = "|cFF32CD32"
local ORANGE= "|cFFFFA500"
local AQUA  = "|cFF00FFFF"
local GREEN  = "|cff00ff00"


function AG:CreateSearchFrame()
-------------------Search Scroll Frame-------------------
local ROW_HEIGHT = 36   -- How tall is each row?
local MAX_ROWS = 11      -- How many rows can be shown at once?

function AG:SetupSearchTable(db, firstBag, lastBag)
    if not db then return end
    firstBag = firstBag or 1
    lastBag = lastBag or 13
    local sorted = {[1] = {}}
        local cNum = 1
        for bagNum, bags in ipairs(db) do
            if bags.numSlots and  (bagNum >= firstBag) and (bagNum <= lastBag) then
                for bag = 1, bags.numSlots do
                    if #sorted[cNum] == MAX_COLUMNS then tinsert(sorted, {}) cNum = cNum + 1 end
                    if bags[bag] and type(bags[bag]) == "table" then
                        tinsert(sorted[cNum], bags[bag])
                    end
                end
            end
        end
    return sorted
end


------------------ScrollFrameTooltips---------------------------

	self.uiFrame.SearchScrollFrame = CreateFrame("Frame", "AltsGaloreSearchScrollFrame", self.uiFrame.searchTab)
	self.uiFrame.SearchScrollFrame:EnableMouse(true)
	self.uiFrame.SearchScrollFrame:SetSize(800, (ROW_HEIGHT + 12) * (MAX_ROWS))
    self.uiFrame.SearchScrollFrame:SetPoint("BOTTOMRIGHT", self.uiFrame.searchTab, -16, 16)
	self.uiFrame.SearchScrollFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	self.uiFrame.SearchScrollFrame.lable = self.uiFrame.SearchScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.SearchScrollFrame.lable:SetJustifyH("LEFT")
	self.uiFrame.SearchScrollFrame.lable:SetPoint("TOPLEFT", self.uiFrame.SearchScrollFrame, 2, 15)
	self.uiFrame.SearchScrollFrame.lable:SetText("Bags")

    local currentDB
	function AG:SearchScrollFrameUpdate(db)
        if not db and not currentDB then return end
        currentDB = db or currentDB
		local maxValue = #currentDB
		FauxScrollFrame_Update(self.uiFrame.SearchScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(self.uiFrame.SearchScrollFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
            local row = self.uiFrame.SearchScrollFrame.rows[i]
			if value <= maxValue then
                if i == 1 then
                    row:SetPoint("TOPLEFT", self.uiFrame.SearchScrollFrame, 20, -20)
                else
                    row:SetPoint("BOTTOM", self.uiFrame.SearchScrollFrame.rows[i-1], 0, -45)
                end
                    local button = self.uiFrame.SearchScrollFrame.rows[i]

                    local function SetButton()
                        _G[button:GetName().."IconTexture"]:SetSize(ROW_HEIGHT,ROW_HEIGHT)
                        _G[button:GetName().."IconTexture"]:SetAllPoints(button)
                        SetItemButtonTexture(button, button.itemTexture)
                        SetItemButtonQuality(button, button.quality)
                        SetItemButtonCount(button, button.count)
                    end
                    if i == 1 then
                        button:SetPoint("LEFT", row, 0, 0)
                    else
                        button:SetPoint("LEFT", self.uiFrame.SearchScrollFrame.rows[i]["button"..i-1], "RIGHT", 10, 0)
                    end
                    button:Show()
                    button.itemTexture, button.count, button.quality, button.itemLink = EMPTY_SLOT, nil, nil, nil
                    SetButton()
                    if not currentDB[value][i] then
                        button:Hide()
                    elseif currentDB[value][i] ~= "EmptySlot" then
                        local item = Item:CreateFromID(currentDB[value][i][1])
                        item:ContinueOnLoad(function()
                            local itemData = {GetItemInfo(currentDB[value][i][1])}
                            button.itemLink, button.itemTexture, button.quality = itemData[2], itemData[10], itemData[3]
                            button.count = currentDB[value][i][2]
                            SetButton()
                        end)
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

	local rows = setmetatable({}, { __index = function(t, i)
        local row = CreateFrame("Button", "$parentRow"..i, self.uiFrame.SearchScrollFrame , "ItemButtonTemplate")
        row:SetSize(ROW_HEIGHT * MAX_COLUMNS + 0.5, ROW_HEIGHT)
            row:SetSize(ROW_HEIGHT, ROW_HEIGHT)
            row:SetScript("OnShow", function(button)
                if GameTooltip:GetOwner() == button:GetName() then
                    self:ItemTemplate_OnEnter(button)
                end
            end)
            row:SetScript("OnEnter", function(button)
                self:ItemTemplate_OnEnter(button)
            end)
            row:SetScript("OnLeave", self.ItemTemplate_OnLeave)
		rawset(t, i, row)
		return row
	end })

	self.uiFrame.SearchScrollFrame.rows = rows

end

AG:CreateSearchFrame()