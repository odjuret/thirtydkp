local addonName, addonNamespace = ... 

-- Initializing the core global variables
addonNamespace.Core = {}  

local View = addonNamespace.View
local Core = addonNamespace.Core


-------------------------------------------------------
-- Main event handler. Processing all incoming events
--------------------------------------------------------
function ThirtyDKP_OnEvent(self, event, arg1, ...)

    -- TODO: handle all other events, boss kill, bid command, etc 

    if event == "ADDON_LOADED" then
        print("ThirtyDKP: event:"..event.." arg1:"..arg1)

		ThirtyDKP_OnInitialize(event, arg1)
        self:UnregisterEvent("ADDON_LOADED")
    end
end 


function ThirtyDKP_OnInitialize(event, name)		-- This is the FIRST function to run on load triggered registered events at bottom of file
	if (name ~= "ThirtyDKP") then return end     -- if its not this addon, return.

	
	----------------------------------
    -- Register Slash Commands
    ----------------------------------
    SLASH_ThirtyDKP1 = "/tdkp";
    SLASH_ThirtyDKP2 = "/thirtydkp";
    SlashCmdList.ThirtyDKP = function()
        if not View.ThirtyDKP_UIInitialized then
            View:InitUI();
        end

        View.ThirtyDKP_MainFrame:SetShown(true);
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

    if(event == "ADDON_LOADED") then

	    ------------------------------------
	    --	Import SavedVariables
	    ------------------------------------
	    -- saved variables starts as nil. we want a empty table
        if not ThirtyDKP_Database_DKPTable then ThirtyDKP_Database_DKPTable = {} end;
        Core.DKPTableCopy 		= ThirtyDKP_Database_DKPTable;	
        Core.DKPTableNumRows    = 0;
        if #ThirtyDKP_Database_DKPTable > 0 then Core.DKPTableNumRows = #ThirtyDKP_Database_DKPTable end;

		table.sort(ThirtyDKP_Database_DKPTable, function(a, b)
			return a["player"] < b["player"]
		end)
		
	end
end

----------------------------------
-- Register Events and Initialise AddOn, this should be done in a Init.lua file
----------------------------------

local events = CreateFrame("Frame", "EventsFrame");
events:RegisterEvent("ADDON_LOADED");
--events:RegisterEvent("BOSS_KILL");
events:SetScript("OnEvent", ThirtyDKP_OnEvent);