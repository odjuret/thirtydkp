local addonName, ThirtyDKP = ...   

local View = ThirtyDKP.View
local DAL = ThirtyDKP.DAL
local Core = ThirtyDKP.Core

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

function Core:Print(args)
    print("|cffffcc00[ThirtyDKP]:|r |cffa30f2d"..args.."|r")
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
    end

    if event == "LOOT_OPENED" then
        Core:HandleLootWindow()
    end

    if event == "BOSS_KILL" then
        Core:HandleBossKill(arg1, ...)
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
                Core:ManualAddToLootTable(arg2)
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
    DAL:InitializeCurrentLootTable();
    DAL:InitializeDKPHistory();
    Core:InitializeComms();

    if not View:IsInitialized() then
        View:Initialize();
    end

    Core:Print("loaded. Type /tdkp to view dkp table and options.")
end

----------------------------------
-- Register Events and Initialise AddOn, this should be done in a Init.lua file
----------------------------------

local events = CreateFrame("Frame", "TDKPEventsFrame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("LOOT_OPENED");
events:RegisterEvent("BOSS_KILL");
events:SetScript("OnEvent", ThirtyDKP_OnEvent);