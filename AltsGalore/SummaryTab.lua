local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local LIMEGREEN = "|cFF32CD32"
local ORANGE= "|cFFFFA500"
local AQUA  = "|cFF00FFFF"
local GREEN  = "|cff00ff00"


------------------Create Summary Scroll Frame---------------------------
function AG:SummaryTabCreate()

	self.uiFrame.SummaryList = {
		"Currencys"
	}
	self.selectedSummaryList = "Currencys"

	--ScrollFrame

	local ROW_HEIGHT = 16   -- How tall is each row?
	local MAX_ROWS = 33      -- How many rows can be shown at once?

	self.uiFrame.SummarySelectionScrollFrame = CreateFrame("Frame", "AltsGaloreSummarySelectionScrollFrame", self.uiFrame.summaryTab)
	self.uiFrame.SummarySelectionScrollFrame:EnableMouse(true)
	self.uiFrame.SummarySelectionScrollFrame:SetPoint("BOTTOMLEFT", self.uiFrame.summaryTab, 16, 16)
	self.uiFrame.SummarySelectionScrollFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	self.uiFrame.SummarySelectionScrollFrame.lable = self.uiFrame.SummarySelectionScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.SummarySelectionScrollFrame.lable:SetJustifyH("LEFT")
	self.uiFrame.SummarySelectionScrollFrame.lable:SetPoint("TOPLEFT", self.uiFrame.SummarySelectionScrollFrame, 2, 15)
    self.uiFrame.SummarySelectionScrollFrame.lable:SetText("Selection")

	function AG:SummarySelectionScrollFrameUpdate()
        local list = self.uiFrame.SummaryList
		local maxValue = #list
		FauxScrollFrame_Update(self.uiFrame.SummarySelectionScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(self.uiFrame.SummarySelectionScrollFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
			self.uiFrame.SummarySelectionScrollFrame.rows[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
			self.uiFrame.SummarySelectionScrollFrame.rows[i]:SetChecked(false)
			if value <= maxValue then
				local row = self.uiFrame.SummarySelectionScrollFrame.rows[i]
                row.Text:SetText(list[value])
				row:SetScript("OnClick", function()
                    self.selectedSummaryList = list[value]
					self:SummarySelectionScrollFrameUpdate()
				end)
                if self.selectedSummaryList == list[value] then
				    row:SetChecked(true)
                end
                row:Show()
            else
                self.uiFrame.SummarySelectionScrollFrame.rows[i]:Hide()
			end
		end
	end

	self.uiFrame.SummarySelectionScrollFrame.scrollBar = CreateFrame("ScrollFrame", "AltsGaloreSummarySelectionScrollFrameScrollBar", self.uiFrame.SummarySelectionScrollFrame, "FauxScrollFrameTemplate")
	self.uiFrame.SummarySelectionScrollFrame.scrollBar:SetPoint("TOPLEFT", 0, -8)
	self.uiFrame.SummarySelectionScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -30, 8)
	self.uiFrame.SummarySelectionScrollFrame.scrollBar:SetScript("OnVerticalScroll", function(scroll, offset)
		scroll.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		self:SummarySelectionScrollFrameUpdate()
	end)

	local rows = setmetatable({}, { __index = function(t, i)
		local row = CreateFrame("CheckButton", "$parentRow"..i, self.uiFrame.SummarySelectionScrollFrame )
		row:SetSize(140, ROW_HEIGHT)
		row:SetNormalFontObject(GameFontHighlightLeft)
        row:SetCheckedTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
		row.Text = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
		row.Text:SetSize(140, ROW_HEIGHT)
		row.Text:SetPoint("LEFT",row)
        row.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
		row.Text:SetJustifyH("LEFT")
		if i == 1 then
			row:SetPoint("TOPLEFT", self.uiFrame.SummarySelectionScrollFrame, 8, -8)
		else
			row:SetPoint("TOPLEFT", self.uiFrame.SummarySelectionScrollFrame.rows[i-1], "BOTTOMLEFT")
		end
		rawset(t, i, row)
		return row
	end })

	self.uiFrame.SummarySelectionScrollFrame.rows = rows

    -------------------Search Scroll Frame-------------------
    local ROW_HEIGHT = 36   -- How tall is each row?
    local MAX_ROWS = 11      -- How many rows can be shown at once?


	self.uiFrame.SummaryDataScrollFrame = CreateFrame("Frame", "AltsGaloreSummaryDataScrollFrame", self.uiFrame.SummarySelectionScrollFrame)
	self.uiFrame.SummaryDataScrollFrame:EnableMouse(true)
	self.uiFrame.SummaryDataScrollFrame:SetSize(800, (ROW_HEIGHT + 12) * (MAX_ROWS) + 24)
    self.uiFrame.SummarySelectionScrollFrame:SetSize(150, self.uiFrame.SummaryDataScrollFrame:GetHeight())
    self.uiFrame.SummaryDataScrollFrame:SetPoint("LEFT", self.uiFrame.SummarySelectionScrollFrame, "RIGHT", 0, 0)
	self.uiFrame.SummaryDataScrollFrame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	self.uiFrame.SummaryDataScrollFrame.lable = self.uiFrame.SummaryDataScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.SummaryDataScrollFrame.lable:SetJustifyH("LEFT")
	self.uiFrame.SummaryDataScrollFrame.lable:SetPoint("TOPLEFT", self.uiFrame.SummaryDataScrollFrame, 66, -15)
    self.uiFrame.SummaryDataScrollFrame.lable:SetFont("Fonts\\FRIZQT__.TTF", 15)
	self.uiFrame.SummaryDataScrollFrame.lable:SetText("Item / Item Type")
    self.uiFrame.SummaryDataScrollFrame.lable2 = self.uiFrame.SummaryDataScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.SummaryDataScrollFrame.lable2:SetJustifyH("LEFT")
	self.uiFrame.SummaryDataScrollFrame.lable2:SetPoint("LEFT", self.uiFrame.SummaryDataScrollFrame.lable, "RIGHT", 95, 0)
	self.uiFrame.SummaryDataScrollFrame.lable2:SetText("Character")
    self.uiFrame.SummaryDataScrollFrame.lable2:SetFont("Fonts\\FRIZQT__.TTF", 15)
    self.uiFrame.SummaryDataScrollFrame.lable3 = self.uiFrame.SummaryDataScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.uiFrame.SummaryDataScrollFrame.lable3:SetJustifyH("LEFT")
	self.uiFrame.SummaryDataScrollFrame.lable3:SetPoint("LEFT", self.uiFrame.SummaryDataScrollFrame.lable2, "RIGHT", 88, 0)
	self.uiFrame.SummaryDataScrollFrame.lable3:SetText("Location")
    self.uiFrame.SummaryDataScrollFrame.lable3:SetFont("Fonts\\FRIZQT__.TTF", 15)

	self.uiFrame.summaryTab.currencyDisplay = {}

	function AG:CreateCurrencyTableDisplay()
		local display = self.uiFrame.summaryTab.currencyDisplay
		local currentGroup
		for name, char in pairs(self.realmDB) do
			if name ~= "currency" then
				for _, currency in ipairs(char.currency) do
					if type(currency) == "string" then
						if not display[currency] then
							display[currency] = {}
						end
						currentGroup = currency
					else
						if not display[currentGroup] then display[currentGroup] = {} end
						if not display[currentGroup][name] then display[currentGroup][name] = {} end
						if currency[3] then
							display[currentGroup][name][currency[3]] = currency
						end
					end
				end
			end
		end
	end

	function AG:SummaryDataScrollFrameUpdate()
        if not self.SearchResults then return end
		local maxValue = #self.SearchResults
		FauxScrollFrame_Update(self.uiFrame.SummaryDataScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(self.uiFrame.SummaryDataScrollFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
            local row = self.uiFrame.SummaryDataScrollFrame.rows[i]
			if value <= maxValue then
                if i == 1 then
                    row:SetPoint("TOPLEFT", self.uiFrame.SummaryDataScrollFrame, 20, -44)
                else
                    row:SetPoint("BOTTOM", self.uiFrame.SummaryDataScrollFrame.rows[i-1], 0, -45)
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

	self.uiFrame.SummaryDataScrollFrame.scrollBar = CreateFrame("ScrollFrame", "AltsGaloreSummaryDataScrollFrameScrollBar", self.uiFrame.SummaryDataScrollFrame, "FauxScrollFrameTemplate")
	self.uiFrame.SummaryDataScrollFrame.scrollBar:SetPoint("TOPLEFT", 0, -8)
	self.uiFrame.SummaryDataScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -30, 8)
	self.uiFrame.SummaryDataScrollFrame.scrollBar:SetScript("OnVerticalScroll", function(scroll, offset)
		scroll.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		self:SummaryDataScrollFrameUpdate()
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
        local row = CreateFrame("Button", "$parentRow"..i, self.uiFrame.SummaryDataScrollFrame)
            row:SetSize(ROW_HEIGHT + 0.5, ROW_HEIGHT)
            row:SetScript("OnEnter", function(button) self:ItemTemplate_OnEnter(button) end)
            row:SetScript("OnLeave", self.ItemTemplate_OnLeave)
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

	self.uiFrame.SummaryDataScrollFrame.rows = rows

end

AG:SummaryTabCreate()
