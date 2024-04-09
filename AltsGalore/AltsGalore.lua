local AG = LibStub("AceAddon-3.0"):NewAddon("AltsGalore", "AceTimer-3.0", "AceEvent-3.0")
ALTSGALORE = AG
AG.dewdrop = AceLibrary("Dewdrop-2.0")
AG.Version = 1

local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
AG.defaultIcon = "Interface\\Icons\\INV_Misc_Book_06"

--Set Savedvariables defaults
local DefaultSettings  = {
    --hideMenu        = { false, Frame = "AltsGaloreStandaloneButton", CheckBox = "AltsGaloreOptionsHideMenu"},
    minimap         = { false, CheckBox = "AltsGaloreOptionsHideMinimap"},
    txtSize         = 12,
}

local CharDefaultSettings = {

}

--[[ DB = Name of the db you want to setup
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
local function setupSettings(db, defaultList)
    for table, v in pairs(defaultList) do
        if not db[table] then
            if type(v) == "table" then
                db[table] = v[1]
            else
                db[table] = v
            end
        end
        if type(v) == "table" then
            if v.CheckBox then
                _G[v.CheckBox]:SetChecked(db[table])
            end
            if v.Text then
                _G[v.Text]:SetText(db[table])
            end
            if v.Frame then
                if db[table] then _G[v.Frame]:Hide() else _G[v.Frame]:Show() end
            end
        end
    end
end

function AG:OnEnable()
    self:InitializeMinimap()
    self:SetFrameTab("AltsGaloreUiSummaryTab")
    --self.standaloneButton:SetScale(self.db.buttonScale or 1)
end

function AG:OnInitialize()
    AltsGaloreDB = AltsGaloreDB or {}
    AltsGaloreCharDB = AltsGaloreCharDB or {}
    self.db = AltsGaloreDB
    self.charDB = AltsGaloreCharDB
    setupSettings(self.db, DefaultSettings)
    setupSettings(self.charDB, CharDefaultSettings)
    --Enable the use of /AltsGalore slash command
    ALTSGALORE1 = "/altsgalore"
    ALTSGALORE2 = "/ag"
    SlashCmdList["ALTSGALORE"] = function(msg)
        ALTSGALORE:SlashCommand(msg)
    end
end

--[[
AG:SlashCommand(msg):
msg - takes the argument for the /mysticextended command so that the appropriate action can be performed
If someone types /mysticextended, bring up the options box
]]
function AG:SlashCommand(msg)
    local cmd, arg = string.split(" ", msg, 2)
	cmd = string.lower(cmd) or nil
	arg = arg or nil
    if cmd == "reset" then
        AltsGaloreDB = nil
        self:OnInitialize()
        DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
    elseif cmd == "options" then
        self:OptionsToggle()
    else
        self:ToggleStandaloneButton()
    end
end
