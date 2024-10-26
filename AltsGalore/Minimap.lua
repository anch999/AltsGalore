local AG = LibStub("AceAddon-3.0"):GetAddon("AltsGalore")
local icon = LibStub('LibDBIcon-1.0')

local minimap = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject("AltsGalore", {
    type = 'data source',
    text = "AltsGalore",
    icon = AG.defaultIcon
})

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    AG:UiOnShow()
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function minimap.OnEnter(button)
    AG:OnEnter(button)
end

function AG:ToggleMinimap()
    self.db.minimap = not self.db.minimap
    if self.db.minimap then
      icon:Hide('AltsGalore')
    else
      icon:Show('AltsGalore')
    end
end

function AG:InitializeMinimap()
    if icon then
        self.minimap = {hide = self.db.minimap}
        icon:Register('AltsGalore', minimap, self.minimap)
    end
    minimap.icon = self.defaultIcon
end
