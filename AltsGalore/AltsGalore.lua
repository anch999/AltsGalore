local AG = LibStub("AceAddon-3.0"):NewAddon("AltsGalore", "AceTimer-3.0", "AceEvent-3.0", "SettingsCreater-1.0")
ALTSGALORE = AG
AG.dewdrop = AceLibrary("Dewdrop-2.0")
AG.Version = 1

local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
AG.defaultIcon = "Interface\\Icons\\INV_Misc_Book_06"

--Set Savedvariables defaults
local DefaultSettings  = {
    minimap         = { false },
    txtSize         = 12,
    detailedGuildBankCount = false,
}

local CharDefaultSettings = { }

function AG:OnInitialize()
    --setup dbs
    self.db = self:SetupDB("AltsGaloreDB", DefaultSettings)
    self.charDB = self:SetupDB("AltsGaloreCharDB", CharDefaultSettings)

    --Enable the use of /AltsGalore slash command
    ALTSGALORE1 = "/altsgalore"
    ALTSGALORE2 = "/ag"
    SlashCmdList["ALTSGALORE"] = function(msg)
        ALTSGALORE:SlashCommand(msg)
    end
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
    self.realmBankSelected = "RealmBank"

    if not self.db[self.realm] then self.db[self.realm] = {} end
    if not self.db[self.realm][self.thisChar] then self.db[self.realm][self.thisChar] = {} end
    self.charDB = self.db[self.realm][self.thisChar]
    self.realmDB = self.db[self.realm]
    _, self.charDB.class = UnitClass("player")
    self.uiFrame.characterSelect:SetText(self.selectedCharacter)
    self:UpdateCurrencyDB()
    self:CreateOptionsUI()
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
    if HasJsonCacheData("BANK_PERMISSIONS_PAYLOAD", 0) then
        local json = GetJsonCacheData("BANK_PERMISSIONS_PAYLOAD", 0)
        if json then
            local jsonObject = C_Serialize:FromJSON(json)
            if jsonObject then
                AG.IsPersonalBank = jsonObject.IsPersonalBank
                AG.IsRealmBank = jsonObject.IsRealmBank
            end
        end
    end
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
