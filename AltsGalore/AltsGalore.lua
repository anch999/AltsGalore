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
    detailedGuildBankCount = false,
}

local CharDefaultSettings = { }

--[[ DB = Name of the db you want to setup
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
local function setupSettings(db, defaultList)
    db = db or {}
    for table, v in pairs(defaultList) do
        if not db[table] and db[table] ~= false then
            if type(v) == "table" then
                db[table] = v[1]
            else
                db[table] = v
            end
        end
        if type(v) == "table" then
            if v.CheckBox and _G[v.CheckBox] then
                _G[v.CheckBox]:SetChecked(db[table])
            end
            if v.Text and _G[v.Text] then
                _G[v.Text]:SetText(db[table])
            end
            if v.Frame and _G[v.Frame] then
                if db[table] then _G[v.Frame]:Hide() else _G[v.Frame]:Show() end
            end
        end
    end
    return db
  end

function AG:OnEnable()
    self:InitializeMinimap()
    self:SetFrameTab("summaryTab")
    self.realm = GetRealmName()
    self.thisChar = GetUnitName("player")
    self:RegisterEvent("GUILD_ROSTER_UPDATE")
    self:RegisterEvent("GUILDBANKFRAME_OPENED")
    self:RegisterEvent("GUILDBANKFRAME_CLOSED")
    self:RegisterEvent("BANKFRAME_OPENED")
    self:RegisterEvent("BANKFRAME_CLOSED")
    self:RegisterEvent("BAG_UPDATE")
    self:RegisterEvent("PLAYER_MONEY")
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("MERCHANT_UPDATE")
    self:InitializeStorgeDBs()
    self.selectedCharacter = self.thisChar
    self.realBankSelected = "RealmBank"
    if not self.db[self.realm] then self.db[self.realm] = {} end
    if not self.db[self.realm][self.thisChar] then self.db[self.realm][self.thisChar] = {} end
    self.charDB = self.db[self.realm][self.thisChar]
    self.realmDB = self.db[self.realm]
    self.uiFrame.characterSelect:SetText(self.selectedCharacter)
    AG:UpdateCurrencyDB()
    --self.standaloneButton:SetScale(self.db.buttonScale or 1)
    --Add the AltsGalore to the special frames tables to enable closing wih the ESC key
	tinsert(UISpecialFrames, "AltsGaloreUI")
end

function AG:GUILD_ROSTER_UPDATE()
    self.guild = GetGuildInfo("player")
    self.selectedGuild = self.guild
    self:InitializeStorgeDBs()
    self:UnregisterEvent("GUILD_ROSTER_UPDATE")
end

function AG:GUILDBANKFRAME_OPENED()
    wipe(self.numTabs)
    self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
end

function AG:GUILDBANKFRAME_CLOSED()
    self:UnregisterEvent("GUILDBANKBAGSLOTS_CHANGED")
end

function AG:BANKFRAME_OPENED()
    self.bankFrameOpen = true
    AG:ScanContainer({6,13})
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
end

function AG:BANKFRAME_CLOSED()
    self.bankFrameOpen = false
    self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED")
end

function AG:OnInitialize()
    --setup dbs
    self.db = setupSettings(AltsGaloreDB, DefaultSettings)
    self.charDB = setupSettings(AltsGaloreCharDB, CharDefaultSettings)
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
        self:UiOnShow()
    end
end
