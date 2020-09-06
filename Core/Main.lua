local addonName, ThirtyDKP = ...   

local View = ThirtyDKP.View
local DAL = ThirtyDKP.DAL
local Core = ThirtyDKP.Core

local isAddonAdmin = nil

function Core:IsInSameGuild(playerName)
	for i=1, GetNumGuildMembers() do
		nameFromGuild, _, _, _, _ = GetGuildRosterInfo(i)
		nameFromGuild = strsub(nameFromGuild, 1, string.find(nameFromGuild, "-")-1) -- required to remove server name from player (can remove in classic if this is not an issue)
		if nameFromGuild == playerName then
			return true;
		end
	end

	return false;
end

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

function Core:FormatTimestamp(timestamp)
	local str = date("%d/%m/%Y %H:%M:%S", timestamp)
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

function Core:RoundNumber(number, decimals)
    return tonumber((("%%.%df"):format(decimals)):format(number))
end

function View:UpdateAllViews()
    View:UpdateDKPTable();

	if Core:IsAddonAdmin() then
		View:UpdateOptionsFrame();
		View:UpdateDKPHistoryFrame();
	end
end


-------------------------------------------------------
-- Main event controller. Delegates all incoming events
--------------------------------------------------------
function ThirtyDKP_OnEvent(self, event, arg1, ...)

    if event == "ADDON_LOADED" then
		ThirtyDKP_OnInitialize(event, arg1)
        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "GET_ITEM_INFO_RECEIVED" then
        Core:HandleGetItemInfoRecieved(arg1, ...)

    elseif event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" then 
        self:UnregisterEvent("GUILD_ROSTER_UPDATE");
        self:UnregisterEvent("PLAYER_GUILD_UPDATE"); 
        Core:CheckDataVersion();   

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


function ThirtyDKP_OnInitialize(event, name)
	if (name ~= "ThirtyDKP") then return end

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
            local delimiterIndex = string.find(argsAsString, ' ');
            local arg1, arg2 = "", "";
            if delimiterIndex ~= nil then
                arg1 = strsub(argsAsString, 1, delimiterIndex-1);
                arg2 = strsub(argsAsString, delimiterIndex+1);
            else
                arg1 = argsAsString
            end

            if arg1 == 'bid' then
                Core:ManualBidAnnounce(arg2)
                return;
            end

            local maybeImport = strsub(argsAsString, 1,6); 
            if maybeImport == 'import' then
                Core:ImportFromMonolithDKP();
                return;
            end

            Core:Print("Unknown command.")
        end
    end

    --[[
    -- Debugging shit thats nice to have during development

    SLASH_RELOADUI1 = "/rl" -- For quicker reloading
    SlashCmdList.RELOADUI = ReloadUI

    SLASH_FRAMESTK1 = "/fs"
    SlashCmdList.FRAMESTK = function()
        LoadAddOn('Blizzard_DebugTools')
        FrameStackTooltip_Toggle()
    end
    --]]

    DAL:InitializeOptions();
    DAL:InitializeDKPTable();
	DAL:InitializeRaid();
    DAL:InitializeCurrentLootTable();
    DAL:InitializeDKPHistory();
    DAL:InitializePersonalSettings();
    DAL:InitializeStandbys();
    Core:InitializeComms();

    C_Timer.After(1, function()
        if not View:IsInitialized() then
            View:Initialize();
        end
    end)

    Core:Print("Loaded.")
    Core:Print("Use /thirtydkp or /tdkp for main window.")
end

----------------------------------
-- Register Events
----------------------------------
local tdkpEvents = CreateFrame("Frame", "TDKPEventsFrame");
tdkpEvents:RegisterEvent("ADDON_LOADED");
tdkpEvents:RegisterEvent("LOOT_OPENED");
tdkpEvents:RegisterEvent("BOSS_KILL");
tdkpEvents:RegisterEvent("GUILD_ROSTER_UPDATE");
tdkpEvents:RegisterEvent("PLAYER_GUILD_UPDATE");
tdkpEvents:SetScript("OnEvent", ThirtyDKP_OnEvent);

function Core:RegisterForRaidMessageEvents()
    tdkpEvents:RegisterEvent("CHAT_MSG_RAID");
    tdkpEvents:RegisterEvent("CHAT_MSG_RAID_LEADER");
end

function Core:UnRegisterForRaidMessageEvents()
    tdkpEvents:UnregisterEvent("CHAT_MSG_RAID");
    tdkpEvents:UnregisterEvent("CHAT_MSG_RAID_LEADER");
end

function Core:RegisterForGetItemInfoEvents()
    tdkpEvents:RegisterEvent("GET_ITEM_INFO_RECEIVED");
end

function Core:UnregisterForGetItemInfoEvents()
    tdkpEvents:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
end