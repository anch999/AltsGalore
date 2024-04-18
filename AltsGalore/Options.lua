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

	self.options.hideMinimap = CreateFrame("CheckButton", "AltsGaloreOptionsHideMinimap", AltsGaloreOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMinimap:SetPoint("TOPLEFT", 380, -60)
	self.options.hideMinimap.Lable = self.options.hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMinimap.Lable:SetJustifyH("LEFT")
	self.options.hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMinimap.Lable:SetText("Hide minimap icon")
	self.options.hideMinimap:SetScript("OnClick", function() self:ToggleMinimap() end)

	self.options.txtSize = CreateFrame("Button", "AltsGaloreOptions_TxtSizeMenu", AltsGaloreOptionsFrame, "UIDropDownMenuTemplate")
	self.options.txtSize:SetPoint("TOPLEFT", 15, -170)
	self.options.txtSize.Lable = self.options.txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.txtSize.Lable:SetJustifyH("LEFT")
	self.options.txtSize.Lable:SetPoint("LEFT", self.options.txtSize, 190, 0)
	self.options.txtSize.Lable:SetText("Menu text size")

end

AG:CreateOptionsUI()

--Hook interface frame show to update options data
InterfaceOptionsFrame:HookScript("OnShow", function()
	if InterfaceOptionsFrame and AltsGaloreOptionsFrame:IsVisible() then
		AltsGalore_OpenOptions()
	end
end)

function AltsGalore_Options_Menu_Initialize()
	local info
	for i = 10, 25 do
		info = {
			text = i;
			func = function() 
				AG.db.txtSize = i 
				local thisID = this:GetID();
				UIDropDownMenu_SetSelectedID(AltsGaloreOptions_TxtSizeMenu, thisID)
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetWidth(AltsGaloreOptions_TxtSizeMenu, 150)
	UIDropDownMenu_SetSelectedID(AltsGaloreOptions_TxtSizeMenu, AG.db.txtSize - 9)
end

function AltsGalore_DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(AltsGaloreOptions_TxtSizeMenu, AltsGalore_Options_Menu_Initialize )
end