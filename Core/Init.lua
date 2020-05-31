local addonName, ThirtyDKP = ... 

-- Initializing the core global variables
ThirtyDKP.Core = {}  

local View = ThirtyDKP.View
local DAL = ThirtyDKP.DAL


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
        if not View:IsInitialized() then
            View:Initialize();
        end

        View:OpenMainFrame();
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
        -- initialize data access
	    DAL:Initialize()
		
	end
end

----------------------------------
-- Register Events and Initialise AddOn, this should be done in a Init.lua file
----------------------------------

local events = CreateFrame("Frame", "EventsFrame");
events:RegisterEvent("ADDON_LOADED");
--events:RegisterEvent("BOSS_KILL");
events:SetScript("OnEvent", ThirtyDKP_OnEvent);