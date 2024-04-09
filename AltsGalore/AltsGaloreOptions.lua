local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")

--Round number
local function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
 end

function AG:OptionsToggle(otherMenu)
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	elseif otherMenu then
		InterfaceOptionsFrame_OpenToCategory("Menu options")
	else
		InterfaceOptionsFrame_OpenToCategory("AltsGalore")
	end
end

function AltsGalore_OpenOptions()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	AltsGalore_DropDownInitialize()
	AG:DeleteEntryScrollFrameUpdate()
end

--Creates the options frame and all its assets

function AG:CreateOptionsUI()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	self.options = { frame = {} }
		self.options.frame.panel = CreateFrame("FRAME", "AltsGaloreOptionsFrame", UIParent, nil)
    	local fstring = self.options.frame.panel:CreateFontString(self.options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText("AltsGalore Settings")
		fstring:SetPoint("TOPLEFT", 15, -15)
		self.options.frame.panel.name = "AltsGalore"
		InterfaceOptions_AddCategory(self.options.frame.panel)

	self.options.hideMenu = CreateFrame("CheckButton", "AltsGaloreOptionsHideMenu", AltsGaloreOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMenu:SetPoint("TOPLEFT", 30, -60)
	self.options.hideMenu.Lable = self.options.hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMenu.Lable:SetJustifyH("LEFT")
	self.options.hideMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMenu.Lable:SetText("Hide Standalone Button")
	self.options.hideMenu:SetScript("OnClick", function() 
		if self.db.hideMenu then
			self.standaloneButton:Show()
			self.db.hideMenu = false
		else
			self.standaloneButton:Hide()
			self.db.hideMenu = true
		end
	end)

	self.options.hideNoMouseOver = CreateFrame("CheckButton", "AltsGaloreOptionsHideNoMouseOver", AltsGaloreOptionsFrame, "UICheckButtonTemplate")
	self.options.hideNoMouseOver:SetPoint("TOPLEFT", 30, -95)
	self.options.hideNoMouseOver.Lable = self.options.hideNoMouseOver:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideNoMouseOver.Lable:SetJustifyH("LEFT")
	self.options.hideNoMouseOver.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideNoMouseOver.Lable:SetText("Only Show Standalone Button on Hover")
	self.options.hideNoMouseOver:SetScript("OnClick", function()
		if self.db.hideNoMouseOver then
			AltsGaloreOptionsFrame:Show()
			self.db.hideNoMouseOver = false
		else
			AltsGaloreOptionsFrame:Hide()
			self.db.hideNoMouseOver = true
		end
	end)

	self.options.hideMinimap = CreateFrame("CheckButton", "AltsGaloreOptionsHideMinimap", AltsGaloreOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMinimap:SetPoint("TOPLEFT", 380, -60)
	self.options.hideMinimap.Lable = self.options.hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMinimap.Lable:SetJustifyH("LEFT")
	self.options.hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMinimap.Lable:SetText("Hide minimap icon")
	self.options.hideMinimap:SetScript("OnClick", function() self:ToggleMinimap() end)

	self.options.autoDelete = CreateFrame("CheckButton", "AltsGaloreOptionsAutoDelete", AltsGaloreOptionsFrame, "UICheckButtonTemplate")
	self.options.autoDelete:SetPoint("TOPLEFT", 380, -95)
	self.options.autoDelete.Lable = self.options.autoDelete:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.autoDelete.Lable:SetJustifyH("LEFT")
	self.options.autoDelete.Lable:SetPoint("LEFT", 30, 0)
	self.options.autoDelete.Lable:SetText("Delete vanity items after summoning")
	self.options.autoDelete:SetScript("OnClick", function() self.db.deleteItem = not self.db.deleteItem end)

	self.options.autoMenu = CreateFrame("CheckButton", "AltsGaloreOptionsAutoMenu", AltsGaloreOptionsFrame, "UICheckButtonTemplate")
	self.options.autoMenu:SetPoint("TOPLEFT", 30, -130)
	self.options.autoMenu.Lable = self.options.autoMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.autoMenu.Lable:SetJustifyH("LEFT")
	self.options.autoMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.autoMenu.Lable:SetText("Show menu on mouse over")
	self.options.autoMenu:SetScript("OnClick", function() self.db.autoMenu = not self.db.autoMenu end)

	self.options.txtSize = CreateFrame("Button", "AltsGaloreOptions_TxtSizeMenu", AltsGaloreOptionsFrame, "UIDropDownMenuTemplate")
	self.options.txtSize:SetPoint("TOPLEFT", 15, -170)
	self.options.txtSize.Lable = self.options.txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.txtSize.Lable:SetJustifyH("LEFT")
	self.options.txtSize.Lable:SetPoint("LEFT", self.options.txtSize, 190, 0)
	self.options.txtSize.Lable:SetText("Menu text size")

	self.options.buttonScale = CreateFrame("Slider", "AltsGaloreOptionsButtonScale", AltsGaloreOptionsFrame,"OptionsSliderTemplate")
	self.options.buttonScale:SetSize(240,16)
	self.options.buttonScale:SetPoint("TOPLEFT", 380,-150)
	self.options.buttonScale:SetMinMaxValues(0.25, 1.5)
	_G[self.options.buttonScale:GetName().."Text"]:SetText("Standalone Button Scale: ".." ("..round(self.options.buttonScale:GetValue(),2)..")")
	_G[self.options.buttonScale:GetName().."Low"]:SetText(0.25)
	_G[self.options.buttonScale:GetName().."High"]:SetText(1.5)
	self.options.buttonScale:SetValueStep(0.01)
	self.options.buttonScale:SetScript("OnShow", function() self.options.buttonScale:SetValue(self.db.buttonScale or 1) end)
    self.options.buttonScale:SetScript("OnValueChanged", function()
		_G[self.options.buttonScale:GetName().."Text"]:SetText("Standalone Button Scale: ".." ("..round(self.options.buttonScale:GetValue(),2)..")")
        self.db.buttonScale = self.options.buttonScale:GetValue()
		if self.standaloneButton then
        	self.standaloneButton:SetScale(self.db.buttonScale)
		end
    end)

	self.options.profileSelect2 = CreateFrame("Button", "AltsGaloreOptions_ProfileSelectMenu2", AltsGaloreOptionsFrame, "UIDropDownMenuTemplate")
	self.options.profileSelect2:SetPoint("TOPLEFT", 15, -210)
	self.options.profileSelect2.Lable = self.options.profileSelect2:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.profileSelect2.Lable:SetJustifyH("LEFT")
	self.options.profileSelect2.Lable:SetPoint("LEFT", self.options.profileSelect2, 190, 0)
	self.options.profileSelect2.Lable:SetText("Profile selection")

	------------------------------ Profile Settings Panel ------------------------------

	self.options.frame.profilePanel = CreateFrame("FRAME", "AltsGaloreAddItemsPanel", UIParent, nil)
		local fstring = self.options.frame.profilePanel:CreateFontString(self.options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText("Menu options")
		fstring:SetPoint("TOPLEFT", 30, -15)
		self.options.frame.profilePanel.name = "Menu options"
		self.options.frame.profilePanel.parent = "AltsGalore"
		InterfaceOptions_AddCategory(self.options.frame.profilePanel)

	self.options.profileSelect = CreateFrame("Button", "AltsGaloreOptions_ProfileSelectMenu", AltsGaloreAddItemsPanel, "UIDropDownMenuTemplate")
	self.options.profileSelect:SetPoint("TOPLEFT", 15, -50)
	self.options.profileSelect.Lable = self.options.profileSelect:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.profileSelect.Lable:SetJustifyH("LEFT")
	self.options.profileSelect.Lable:SetPoint("LEFT", self.options.profileSelect, 190, 0)
	self.options.profileSelect.Lable:SetText("Profile selection")

	self.options.addButton = CreateFrame("Button", "AltsGaloreOptionsAddButton", AltsGaloreAddItemsPanel, "ItemButtonTemplate")
	self.options.addButton:SetPoint("TOPLEFT", 280, -113)
	self.options.addButton.Lable = self.options.addButton:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.addButton.Lable:SetJustifyH("LEFT")
	self.options.addButton.Lable:SetPoint("LEFT", self.options.addButton, 0, 37)
	self.options.addButton.Lable:SetText("Add item/spell")
	self.options.addButton:SetScript("OnClick", function()
		self:AddItem()
		self:DeleteEntryScrollFrameUpdate()
	end)
	self.options.addButton:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT", 0, 20)
		GameTooltip:AddLine("Drag and drop a spell or item to add it to list")
		GameTooltip:Show()
	end)
	self.options.addButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

end

AG:CreateOptionsUI()

--Hook interface frame show to update options data
InterfaceOptionsFrame:HookScript("OnShow", function()
	if InterfaceOptionsFrame and AltsGaloreOptionsFrame:IsVisible() then
		AltsGalore_OpenOptions()
	end
end)
