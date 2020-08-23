local addonName, ThirtyDKP = ...

local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local DAL = ThirtyDKP.DAL;
local Const = ThirtyDKP.View.Constants;

-- Main addon window
local TdkpIsInitialized = false;
local TdkpFrame = nil;

local TDKP_MAIN_FRAME_TITLE = "Thirty DKP"


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
    TdkpFrame.upToDateFrame.text:SetText("Data:"..colorizedText);

    View:AttachHoverOverTooltipAndOnclick(TdkpFrame.upToDateFrame, "Your local data is"..colorizedText, hoverOverText, function ()
        StaticPopupDialogs["TDKP_DATA_STATUS_FRAME_CLICK"] = {
            text = "Do you want to re-check if your data is up to date?",
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

local function CreateTdkpMainFrameButton(text, relativePoint, parentFrame, relativePointOnParentFrame, x, y)
    local b = CreateFrame("Button", nil, TdkpFrame, "GameMenuButtonTemplate");
    b:SetPoint(relativePoint, parentFrame, relativePointOnParentFrame, x, y);
    b:SetSize(80, Const.ButtonHeight);
    b:SetText(text);
    b:SetNormalFontObject("GameFontNormal");
    b:SetHighlightFontObject("GameFontHighlight");
    return b
end

local function CreateRightSideAdminPanel()
    local adminPanel = CreateFrame("Frame", nil, TdkpFrame, nil);
    adminPanel:SetSize(100, 370);
    adminPanel:SetPoint(Const.BOTTOM_RIGHT_POINT, TdkpFrame, Const.BOTTOM_RIGHT_POINT, 0, 0);

    -- building buttons from the bottom and up
    adminPanel.removePlayerBtn = CreateTdkpMainFrameButton("Remove", Const.BOTTOM_RIGHT_POINT, adminPanel, Const.BOTTOM_RIGHT_POINT, -10, 10)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.removePlayerBtn, "Remove players", "Removes selected players from the DKP table.", function()
        local selectedPlayers = View:GetSelectedDKPTableEntries();
        StaticPopupDialogs["ADD_GUILD_ENTRIES"] = {
            text = "Are you sure you want to remove selected players from the DKP table?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                DAL:RemoveFromDKPTable(selectedPlayers);
                View:UpdateDKPTable();
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("ADD_GUILD_ENTRIES")
    end);

    adminPanel.addGuildToTableBtn = CreateTdkpMainFrameButton("Add Guild", Const.BOTTOM_LEFT_POINT, adminPanel.removePlayerBtn, Const.TOP_LEFT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.addGuildToTableBtn, "Add guild members to DKP table", "Adds guild members that aren't in the dkp table", function()
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

    adminPanel.addRaidToTableBtn = CreateTdkpMainFrameButton("Add Raid", Const.BOTTOM_LEFT_POINT, adminPanel.addGuildToTableBtn, Const.TOP_LEFT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.addRaidToTableBtn, "Add raid members to DKP table", "Given that theyre in the guild obviously", function()
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

    adminPanel.dkpAdminsBtn = CreateTdkpMainFrameButton("Admins", Const.BOTTOM_RIGHT_POINT, adminPanel.addRaidToTableBtn, Const.TOP_RIGHT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.dkpAdminsBtn, "Admins Management", "Manage DKP admins for your guild. Admins can change dkp options, adjust dkp, start dkp awarding raids, etc", function()
        View:HideOptionsFrame();
        View:HideDKPAdjustFrame();
        View:HideDKPHistoryFrame();
        View:ToggleDKPAdminsFrame()
    end)

    adminPanel.broadcastBtn = CreateTdkpMainFrameButton("Broadcast", Const.BOTTOM_RIGHT_POINT, adminPanel.dkpAdminsBtn, Const.TOP_RIGHT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.broadcastBtn, "Broadcasts ThirtyDKP data", "Attempts to broadcast out your dkp data to other online members:\ndkp table, dkp history and addon options", function()
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

    adminPanel.adminHeader = adminPanel:CreateFontString(nil, Const.OVERLAY_LAYER);
    adminPanel.adminHeader:SetFontObject("ThirtyDKPSmall");
    adminPanel.adminHeader:SetPoint(Const.BOTTOM_LEFT_POINT, adminPanel.broadcastBtn, Const.TOP_LEFT_POINT, 0, 5);
    adminPanel.adminHeader:SetSize(80, Const.ButtonHeight);
    adminPanel.adminHeader:SetText("Admin.")


    adminPanel.dkpHistoryBtn = CreateTdkpMainFrameButton("History", Const.BOTTOM_RIGHT_POINT, adminPanel.adminHeader, Const.TOP_RIGHT_POINT, 0, 10)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.dkpHistoryBtn, "DKP History", "Manage DKP history for your guild.", function()
        View:HideOptionsFrame();
        View:HideDKPAdjustFrame();
        View:HideDKPAdminsFrame()
        View:ToggleDKPHistoryFrame();
    end)

    adminPanel.optionsButton = CreateTdkpMainFrameButton("Options", Const.BOTTOM_RIGHT_POINT, adminPanel.dkpHistoryBtn, Const.TOP_RIGHT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.optionsButton, "DKP Options", "Manage costs and gains", function()
        View:HideDKPAdjustFrame();
        View:HideDKPAdminsFrame();
        View:HideDKPHistoryFrame();
        View:ToggleOptionsFrame();
    end)

    adminPanel.dkpAdjustBtn = CreateTdkpMainFrameButton("Adjust", Const.BOTTOM_RIGHT_POINT, adminPanel.optionsButton, Const.TOP_RIGHT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.dkpAdjustBtn, "DKP Adjustments", "Give on-time and raid completion bonuses.\nManually adjust player DKP.\nApply DKP Decay for guild.", function()
        View:HideOptionsFrame();
        View:HideDKPAdminsFrame()
        View:HideDKPHistoryFrame();
        View:ToggleDKPAdjustFrame();
    end)

    adminPanel.dkpHeader = adminPanel:CreateFontString(nil, Const.OVERLAY_LAYER);
    adminPanel.dkpHeader:SetFontObject("ThirtyDKPSmall");
    adminPanel.dkpHeader:SetPoint(Const.BOTTOM_LEFT_POINT, adminPanel.dkpAdjustBtn, Const.TOP_LEFT_POINT, 0, 5);
    adminPanel.dkpHeader:SetSize(80, Const.ButtonHeight);
    adminPanel.dkpHeader:SetText("DKP.")

end


local function CreateTdkpMainFrame(isAddonAdmin)
    local mainFrameWidth;
    if isAddonAdmin then
        mainFrameWidth = Const.DKPTableWidth + 130 -- make room for options buttons
    else
        mainFrameWidth = Const.DKPTableWidth + 40
    end
    

    TdkpFrame = View:CreateContainerFrame('ThirtyDKP_MainFrame', nil, TDKP_MAIN_FRAME_TITLE, mainFrameWidth, Const.DKPTableRowHeight*14)
	TdkpFrame:SetClampedToScreen(true);
	if isAddonAdmin then
		TdkpFrame:SetSize(420, 400);
	else
		TdkpFrame:SetSize(335, 400);
	end
	TdkpFrame:SetMovable(true);
	TdkpFrame:EnableMouse(true);
	TdkpFrame:RegisterForDrag("LeftButton");
	TdkpFrame:SetScript("OnDragStart", TdkpFrame.StartMoving);
	TdkpFrame:SetScript("OnDragStop", TdkpFrame.StopMovingOrSizing);
    TdkpFrame:SetScript("OnHide", function(self)
        if isAddonAdmin then
            View:HideOptionsFrame();
            View:HideDKPAdjustFrame();
            View:HideDKPHistoryFrame();
            View:HideDKPAdminsFrame()
        end
	end);


    -- up-to-date frame
    TdkpFrame.upToDateFrame = CreateFrame('Button', nil, TdkpFrame);
    TdkpFrame.upToDateFrame:SetSize(100, 30);
    TdkpFrame.upToDateFrame:SetPoint(Const.TOP_LEFT_POINT, ThirtyDKP_MainFrame, Const.TOP_LEFT_POINT, 110, 0);
    TdkpFrame.upToDateFrame:RegisterForClicks("AnyUp");
    TdkpFrame.upToDateFrame.text = TdkpFrame.upToDateFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	TdkpFrame.upToDateFrame.text:SetFontObject("ThirtyDKPTiny");
    TdkpFrame.upToDateFrame.text:SetPoint(Const.LEFT_POINT, TdkpFrame.upToDateFrame, Const.LEFT_POINT, 0, 5);
    
    View:UpdateDataUpToDateFrame()

    if isAddonAdmin then
        CreateRightSideAdminPanel();
    end
end

function View:GetMainFrame()
	return TdkpFrame;
end

function View:OpenMainFrame()
	TdkpFrame:SetShown(true);
end

function View:IsInitialized()
	return TdkpIsInitialized;
end

function View:Initialize()
    if TdkpIsInitialized then return end
    
    local isAddonAdmin = Core:IsAddonAdmin();

	CreateTdkpMainFrame(isAddonAdmin);
    View:CreateDKPTable(TdkpFrame);
    View:CreateBidAnnounceFrame();
    if isAddonAdmin then
        View:CreateOptionsFrame(TdkpFrame);
		View:CreateDKPAdjustFrame(TdkpFrame);
        View:CreateDKPAdminsFrame(TdkpFrame);
        View:CreateDKPHistoryFrame(TdkpFrame);
    end

	TdkpIsInitialized = true;
end
