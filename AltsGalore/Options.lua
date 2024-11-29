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
				Lable = "Menu text size",
				Menu = {10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}
			},
		},
		},
	}
self.options = self:CreateOptionsPages(Options, AltsGaloreDB)

end