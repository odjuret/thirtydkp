local addonName, ThirtyDKP = ...   

local View = ThirtyDKP.View
local DAL = ThirtyDKP.DAL
local Core = ThirtyDKP.Core

local isAddonAdmin = nil

local classColors = {
	["Druid"] = "FF7D0A",
	["Hunter"] =  "ABD473",
	["Mage"] = "40C7EB",
	["Priest"] = "FFFFFF",
	["Rogue"] = "FFF569",
	["Shaman"] = "F58CBA",
	["Paladin"] = "F58CBA",
	["Warlock"] = "8787ED",
	["Warrior"] = "C79C6E"
}

local function GetGuildRankIndex(player)
	if IsInGuild() then
	local name, rank;
	local guildSize,_,_ = GetNumGuildMembers();

		for i=1, tonumber(guildSize) do
			name,_,rank = GetGuildRosterInfo(i)
			name = strsub(name, 1, string.find(name, "-")-1)  -- required to remove server name from player (can remove in classic if this is not an issue)
			if name == player then
				return rank+1;
			end
		end
		return false;
	end
end

local function CheckIsAddonAdmin()
    local admins = DAL:GetAddonAdmins();
    local playerName = UnitName("player");

    if GetGuildRankIndex(playerName) == 1 then -- enforce guild master is always addon admin
        isAddonAdmin = true
        DAL:AddAddonAdmin(playerName)
        return;
    end

    for _, adminName in ipairs(admins) do
        if adminName == playerName then
            isAddonAdmin = true
            return;
        end
    end

    isAddonAdmin = false;
end

function Core:IsAddonAdmin()
    if isAddonAdmin == nil then
        CheckIsAddonAdmin()
    end
    return isAddonAdmin
end


function Core:Print(args)
    print("|cffffcc00[ThirtyDKP]:|r |cffa30f2d"..args.."|r")
end

function Core:FormatTimestamp(timestamp)
	local str = date("%y/%m/%d %H:%M:%S", timestamp)
	return str;
end

-- This also returns false if not in raid
function Core:IsPlayerMasterLooter()
    local _, _, masterlooterRaidID = GetLootMethod();
    if masterlooterRaidID ~= nil then
        local nameFromRaid = GetRaidRosterInfo(masterlooterRaidID)
        if nameFromRaid == UnitName("player") then
            return true
        end
    end

    return false
end

function Core:AddClassColor(stringToColorize, class)
    local classColor = classColors[class]
    
    return "|cff"..classColor..stringToColorize.."|r"
end

function Core:RoundNumber(number, decimals)
    return tonumber((("%%.%df"):format(decimals)):format(number))
end

-------------------------------------------------------
-- Main event controller. Delegates all incoming events
--------------------------------------------------------
function ThirtyDKP_OnEvent(self, event, arg1, ...)
    -- TODO: handle all other events, boss kill, bid command, etc 

    if event == "ADDON_LOADED" then
		ThirtyDKP_OnInitialize(event, arg1)
        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "LOOT_OPENED" then
        Core:HandleLootWindow()

    elseif event == "BOSS_KILL" then
        Core:HandleBossKill(arg1, ...)

    elseif event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" then
        arg1 = strlower(arg1)
        if string.find(arg1, "!bid") == 1 or string.find(arg1, "!pass") == 1 then
            Core:HandleSubmitBidRaidMessage(arg1, ...)
        end

    end
end


function ThirtyDKP_OnInitialize(event, name)		-- This is the FIRST function to run on load triggered registered events at bottom of file
	if (name ~= "ThirtyDKP") then return end     -- if its not this addon, return.

	----------------------------------
    -- Register Slash Commands
    ----------------------------------
    SLASH_ThirtyDKP1 = "/tdkp";
    SLASH_ThirtyDKP2 = "/thirtydkp";
    SlashCmdList.ThirtyDKP = function(argsAsString)
        if not View:IsInitialized() then
            View:Initialize();
        end

        if #argsAsString == 0 then
            View:OpenMainFrame();
        else
            local arg1 = strsub(argsAsString, 1,3); -- todo: this smells
            local arg2 = strsub(argsAsString, 5); 

            if arg1 == 'bid' then
                Core:ManualBidAnnounce(arg2)
            end
        end
    end

    --[[
    Debugging shit thats nice to have during development
    --]]
    SLASH_RELOADUI1 = "/rl" -- For quicker reloading
    SlashCmdList.RELOADUI = ReloadUI

    SLASH_FRAMESTK1 = "/fs"
    SlashCmdList.FRAMESTK = function()
        LoadAddOn('Blizzard_DebugTools')
        FrameStackTooltip_Toggle()
    end

    DAL:InitializeOptions();
    DAL:InitializeDKPTable();
	DAL:InitializeRaid();
    DAL:InitializeCurrentLootTable();
    DAL:InitializeDKPHistory();
    Core:InitializeComms();
    Core:CheckDataVersion(); 

    if not View:IsInitialized() then
        View:Initialize();
    end

    Core:Print("Loaded. Type /tdkp to view dkp table and options.")
end

----------------------------------
-- Register Events and Initialise AddOn, this should be done in a Init.lua file
----------------------------------
local events = CreateFrame("Frame", "TDKPEventsFrame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("LOOT_OPENED");
events:RegisterEvent("BOSS_KILL");
events:SetScript("OnEvent", ThirtyDKP_OnEvent);

function Core:RegisterForRaidMessageEvents()
    events:RegisterEvent("CHAT_MSG_RAID");
    events:RegisterEvent("CHAT_MSG_RAID_LEADER");
end

function Core:UnRegisterForRaidMessageEvents()
    events:UnregisterEvent("CHAT_MSG_RAID");
    events:UnregisterEvent("CHAT_MSG_RAID_LEADER");
end