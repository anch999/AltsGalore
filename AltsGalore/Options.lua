local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")

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
	local Options = {
		AddonName = "AltsGalore",
		TitleText = "AltsGalore Settings",
		{
		Name = "AltsGalore",
		Left = {
			{
				Type = "CheckButton",
				Name = "minimap",
				Lable = "Hide minimap icon",
				OnClick = function()
					self:ToggleMinimap()
				end,
			},
			{
				Type = "Menu",
				Name = "TxtSize",
				Lable = "Menu text size"
			},
		},
		},
	}
self.options = self:CreateOptionsPages(Options, AltsGaloreDB)

end

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
				UIDropDownMenu_SetSelectedID(AltsGaloreOptionsTxtSizeMenu, thisID)
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetWidth(AltsGaloreOptionsTxtSizeMenu, 150)
	UIDropDownMenu_SetSelectedID(AltsGaloreOptionsTxtSizeMenu, AG.db.txtSize - 9)
end

function AltsGalore_DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(AltsGaloreOptionsTxtSizeMenu, AltsGalore_Options_Menu_Initialize )
end