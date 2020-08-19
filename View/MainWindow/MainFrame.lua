local addonName, ThirtyDKP = ...

local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local DAL = ThirtyDKP.DAL;
local Const = ThirtyDKP.View.Constants;

-- Main addon window
local Initialized = false;
local MainFrame = nil;

-- Titles related constants
local MAIN_FRAME_TITLE = "Thirty DKP"


function View:UpdateDataUpToDateFrame(incHoverOverText)
    local colorizedText = ""
    local hoverOverText = ""
    local latestKnownVersionOwner = Core:GetLatestKnownVersionOwner()
    
    if Core:IsDataUpToDate() then
        colorizedText = Core:ColorizePositiveOrNegative(1, " Up-to-date")
    else
        if incHoverOverText ~= nil and incHoverOverText ~= "" then
            hoverOverText = incHoverOverText
        else
            latestKnownVersionOwner = Core:TryToAddClassColor(latestKnownVersionOwner)
            hoverOverText = "Seems like "..latestKnownVersionOwner.." has newer data. \nRequest a broadcast from "..latestKnownVersionOwner.."."
        end
        colorizedText = Core:ColorizePositiveOrNegative(-1, " Outdated")
    end
    MainFrame.upToDateFrame.text:SetText("Data:"..colorizedText);

    View:AttachHoverOverTooltipAndOnclick(MainFrame.upToDateFrame, "Your local data is"..colorizedText, hoverOverText, function ()
        StaticPopupDialogs["TDKP_DATA_STATUS_FRAME_CLICK"] = {
            text = "Do you want to re-sync data with guild?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                Core:CheckDataVersion();
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("TDKP_DATA_STATUS_FRAME_CLICK")
    end)
end

local function CreateMainFrameButton(text, relativePoint, parentFrame, relativePointOnParentFrame, x, y)
    local b = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
    b:SetPoint(relativePoint, parentFrame, relativePointOnParentFrame, x, y);
    b:SetSize(80, Const.ButtonHeight);
    b:SetText(text);
    b:SetNormalFontObject("GameFontNormal");
    b:SetHighlightFontObject("GameFontHighlight");
    return b
end

local function CreateDKPAdjustButton()
    MainFrame.dkpAdjustBtn = CreateMainFrameButton("Adjust", Const.BOTTOM_RIGHT_POINT, MainFrame.optionsButton, Const.TOP_RIGHT_POINT, 0, 0)

    View:AttachHoverOverTooltipAndOnclick(MainFrame.dkpAdjustBtn, "DKP Adjustments", "Give on-time and raid completion bonuses.\nManually adjust player DKP.\nApply DKP Decay for guild.", function()
        View:HideOptionsFrame();
        View:HideTdkpAdminsFrame()
        View:HideDKPHistoryFrame();
        View:ToggleDKPAdjustFrame();
    end)
end

local function CreateDKPOptionsButton()
    MainFrame.optionsButton = CreateMainFrameButton("Options", Const.BOTTOM_RIGHT_POINT, MainFrame.dkpHistoryBtn, Const.TOP_RIGHT_POINT, 0, 0)

    View:AttachHoverOverTooltipAndOnclick(MainFrame.optionsButton, "DKP Options", "Manage costs and gains", function()
        View:HideDKPAdjustFrame();
        View:HideTdkpAdminsFrame();
        View:HideDKPHistoryFrame();
        View:ToggleOptionsFrame();
    end)
end

local function CreateDKPHistoryButton()
    MainFrame.dkpHistoryBtn = CreateMainFrameButton("History", Const.BOTTOM_RIGHT_POINT, MainFrame.broadcastBtn, Const.TOP_RIGHT_POINT, 0, 10)

    View:AttachHoverOverTooltipAndOnclick(MainFrame.dkpHistoryBtn, "DKP History", "Manage DKP history for your guild.", function()
        View:HideOptionsFrame();
        View:HideDKPAdjustFrame();
        View:HideTdkpAdminsFrame()
        View:ToggleDKPHistoryFrame();
    end)
end

local function CreateBroadcastDKPDataButton()
    MainFrame.broadcastBtn = CreateMainFrameButton("Broadcast", Const.BOTTOM_RIGHT_POINT, MainFrame.dkpAdminsBtn, Const.TOP_RIGHT_POINT, 0, 0)

    View:AttachHoverOverTooltipAndOnclick(MainFrame.broadcastBtn, "Broadcasts ThirtyDKP data", "Attempts to broadcast out your dkp data to other online members:\ndkp table, dkp history and addon options", function()
        StaticPopupDialogs["BROADCAST_THIRTYDKPDATA"] = {
            text = "Are you sure you want to broadcast your ThirtyDKP data?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                Core:BroadcastThirtyDKPData();
                View:ShowBroadcastingStatusFrame()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("BROADCAST_THIRTYDKPDATA")
    end)
end

local function CreateDKPAdminsButton()
    MainFrame.dkpAdminsBtn = CreateMainFrameButton("Admins", Const.BOTTOM_RIGHT_POINT, MainFrame.addRaidToTableBtn, Const.TOP_RIGHT_POINT, 0, 0)

    View:AttachHoverOverTooltipAndOnclick(MainFrame.dkpAdminsBtn, "Admins Management", "Manage DKP admins for your guild. Admins can change dkp options, adjust dkp, start dkp awarding raids, etc", function()
        View:HideOptionsFrame();
        View:HideDKPAdjustFrame();
        View:HideDKPHistoryFrame();
        View:ToggleTdkpAdminsFrame()
    end)
end

local function CreateAddRaidToDKPTableButton()
    MainFrame.addRaidToTableBtn = CreateMainFrameButton("Add Raid", Const.BOTTOM_LEFT_POINT, MainFrame.addGuildToTableBtn, Const.TOP_LEFT_POINT, 0, 0)

    View:AttachHoverOverTooltipAndOnclick(MainFrame.addRaidToTableBtn, "Add raid members to DKP table", "Given that theyre in the guild obviously", function()
        -- If you aint in raid
        if not IsInRaid() then
            StaticPopupDialogs["NOT_IN_RAID"] = {
                text = "Well you gotta be in a raid to add raid members to DKP table...",
                button1 = "Oh right...",
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show ("NOT_IN_RAID")
        else
            -- confirmation dialog to remove user(s)
            local selected = "Sure you want to add the entire raid to the DKP table?";
            StaticPopupDialogs["ADD_RAID_ENTRIES"] = {
            text = selected,
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                Core:AddRaidToDKPTable()
                View:UpdateDKPTable()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            }
            StaticPopup_Show ("ADD_RAID_ENTRIES")
        end
    end);
end

local function CreateAddGuildToDKPTableButton()
    MainFrame.addGuildToTableBtn = CreateMainFrameButton("Add Guild", Const.BOTTOM_RIGHT_POINT, MainFrame, Const.BOTTOM_RIGHT_POINT, -10, 10)

    View:AttachHoverOverTooltipAndOnclick(MainFrame.addGuildToTableBtn, "Add guild members to DKP table", "Adds guild members that aren't in the dkp table", function()
        -- If not in guild
        if not IsInGuild() then
            StaticPopupDialogs["NOT_IN_GUILD"] = {
                text = "You need to be in a guild to be able to add guild members to dkp table",
                button1 = "OK",
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show ("NOT_IN_GUILD")
        else
            local selected = "Do you want to add guild members to dkp table?"
            StaticPopupDialogs["ADD_GUILD_ENTRIES"] = {
                text = selected,
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    Core:AddGuildToDKPTable()
                    View:UpdateDKPTable()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("ADD_GUILD_ENTRIES")
        end
    end);
end

local function CreateMainFrame(isAddonAdmin)
    local mainFrameWidth;
    if isAddonAdmin then
        mainFrameWidth = Const.DKPTableWidth + 130 -- make room for options buttons
    else
        mainFrameWidth = Const.DKPTableWidth + 40
    end
    

    MainFrame = View:CreateContainerFrame('ThirtyDKP_MainFrame', nil, MAIN_FRAME_TITLE, mainFrameWidth, Const.DKPTableRowHeight*14)
	MainFrame:SetClampedToScreen(true);
	if isAddonAdmin then
		MainFrame:SetSize(430, 400);
	else
		MainFrame:SetSize(350, 400);
	end
	MainFrame:SetMovable(true);
	MainFrame:EnableMouse(true);
	MainFrame:RegisterForDrag("LeftButton");
	MainFrame:SetScript("OnDragStart", MainFrame.StartMoving);
	MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing);
    MainFrame:SetScript("OnHide", function(self)
        if isAddonAdmin then
            View:HideOptionsFrame();
            View:HideDKPAdjustFrame();
        end
	end);


    -- up-to-date frame
    MainFrame.upToDateFrame = CreateFrame('Button', nil, MainFrame);
    MainFrame.upToDateFrame:SetSize(100, 30);
    MainFrame.upToDateFrame:SetPoint(Const.TOP_LEFT_POINT, ThirtyDKP_MainFrame, Const.TOP_LEFT_POINT, 110, 0);
    MainFrame.upToDateFrame:RegisterForClicks("AnyUp");
    MainFrame.upToDateFrame.text = MainFrame.upToDateFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	MainFrame.upToDateFrame.text:SetFontObject("ThirtyDKPTiny");
    MainFrame.upToDateFrame.text:SetPoint(Const.LEFT_POINT, MainFrame.upToDateFrame, Const.LEFT_POINT, 0, 5);
    
    View:UpdateDataUpToDateFrame()

	-- Buttons

    if isAddonAdmin then
        CreateAddGuildToDKPTableButton()
        
        CreateAddRaidToDKPTableButton()
        
        CreateDKPAdminsButton()
        
        CreateBroadcastDKPDataButton()
        
        CreateDKPHistoryButton()
        
        CreateDKPOptionsButton()
        
        CreateDKPAdjustButton()
        
    end
end

function View:GetMainFrame()
	return MainFrame;
end

function View:OpenMainFrame()
	MainFrame:SetShown(true);
end

function View:IsInitialized()
	return Initialized;
end

function View:Initialize()
    if Initialized then return end
    
    local isAddonAdmin = Core:IsAddonAdmin();

	CreateMainFrame(isAddonAdmin);
    View:CreateDKPTable(MainFrame);
    View:CreateBidAnnounceFrame();
    if isAddonAdmin then
        View:CreateOptionsFrame(MainFrame);
		View:CreateDKPAdjustFrame(MainFrame);
        View:CreateTdkpAdminsFrame(MainFrame);
        View:CreateDKPHistoryFrame(MainFrame);
    end

	Initialized = true;
end
