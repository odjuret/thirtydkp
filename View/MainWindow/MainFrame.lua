local addonName, ThirtyDKP = ...

local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local DAL = ThirtyDKP.DAL;
local Const = ThirtyDKP.View.Constants;

-- Main addon window
local TdkpIsInitialized = false;
local TdkpMainFrame = nil;

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
    TdkpMainFrame.upToDateFrame.text:SetText("Data:"..colorizedText);

    View:AttachHoverOverTooltipAndOnclick(TdkpMainFrame.upToDateFrame, "Your local data is"..colorizedText, hoverOverText, function ()
        StaticPopupDialogs["TDKP_DATA_STATUS_FRAME_CLICK"] = {
            text = "Do you want to re-check if your data is up to date?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                Core:CheckDataVersion(0);
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
    local b = CreateFrame("Button", nil, TdkpMainFrame, "GameMenuButtonTemplate");
    b:SetPoint(relativePoint, parentFrame, relativePointOnParentFrame, x, y);
    b:SetSize(80, Const.ButtonHeight);
    b:SetText(text);
    b:SetNormalFontObject("GameFontNormal");
    b:SetHighlightFontObject("GameFontHighlight");
    return b
end

local function CreateRightSideAdminPanel()
    local adminPanel = CreateFrame("Frame", nil, TdkpMainFrame, nil);
    adminPanel:SetSize(100, 370);
    adminPanel:SetPoint(Const.BOTTOM_RIGHT_POINT, TdkpMainFrame, Const.BOTTOM_RIGHT_POINT, 0, 0);

    -- building buttons from the bottom and up
    adminPanel.removePlayerBtn = CreateTdkpMainFrameButton("Remove", Const.BOTTOM_RIGHT_POINT, adminPanel, Const.BOTTOM_RIGHT_POINT, -10, 10)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.removePlayerBtn, "Remove players", "Removes selected players from the DKP table.", function()
        local selectedPlayers = View:GetSelectedDKPTableEntries();
        StaticPopupDialogs["REMOVE_DKPTABLE_ENTRIES"] = {
            text = "Are you sure you want to remove selected players from the DKP table?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                if #selectedPlayers > 0 then
                    DAL:RemoveFromDKPTable(selectedPlayers);
                    View:UpdateDKPTable();
                else
                    Core:Print("No players selected");
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("REMOVE_DKPTABLE_ENTRIES")
    end);

    adminPanel.addGuildToTableBtn = CreateTdkpMainFrameButton("Add Guild", Const.BOTTOM_LEFT_POINT, adminPanel.removePlayerBtn, Const.TOP_LEFT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.addGuildToTableBtn, "Add guild members to DKP table", "Adds guild members that aren't in the dkp table", function()
        View:HideOptionsFrame();
        View:HideDKPAdjustFrame();
        View:HideDKPAdminsFrame();
        View:HideDKPHistoryFrame();
        View:HideStandbysFrame();
        View:ToggleAddGuildFrame();
    end);

    adminPanel.addRaidToTableBtn = CreateTdkpMainFrameButton("Add Raid", Const.BOTTOM_LEFT_POINT, adminPanel.addGuildToTableBtn, Const.TOP_LEFT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.addRaidToTableBtn, "Add raid members to DKP table", "Given that theyre in the guild obviously", function()
        -- If you aint in raid
        if not IsInRaid() then
            StaticPopupDialogs["TDKP_NOT_IN_RAID"] = {
                text = "Well you gotta be in a raid to add raid members to DKP table...",
                button1 = "Oh right...",
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show ("TDKP_NOT_IN_RAID")
        else
            -- confirmation dialog to remove user(s)
            local selected = "Sure you want to add the entire raid to the DKP table?";
            StaticPopupDialogs["TDKP_ADD_RAID_ENTRIES"] = {
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
            StaticPopup_Show ("TDKP_ADD_RAID_ENTRIES")
        end
    end);

    adminPanel.dkpAdminsBtn = CreateTdkpMainFrameButton("Admins", Const.BOTTOM_RIGHT_POINT, adminPanel.addRaidToTableBtn, Const.TOP_RIGHT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.dkpAdminsBtn, "Admins Management", "Manage DKP admins for your guild. Admins can change dkp options, adjust dkp, start dkp awarding raids, etc", function()
        View:HideOptionsFrame();
        View:HideDKPAdjustFrame();
        View:HideDKPHistoryFrame();
        View:HideAddGuildFrame();
        View:HideStandbysFrame();
        View:ToggleDKPAdminsFrame();
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
    adminPanel.adminHeader:SetText("Admin")


    adminPanel.dkpHistoryBtn = CreateTdkpMainFrameButton("History", Const.BOTTOM_RIGHT_POINT, adminPanel.adminHeader, Const.TOP_RIGHT_POINT, 0, 10)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.dkpHistoryBtn, "DKP History", "Manage DKP history for your guild.", function()
        View:HideOptionsFrame();
        View:HideDKPAdjustFrame();
        View:HideDKPAdminsFrame();
        View:HideAddGuildFrame();
        View:HideStandbysFrame();
        View:ToggleDKPHistoryFrame();
    end)

    adminPanel.optionsButton = CreateTdkpMainFrameButton("Options", Const.BOTTOM_RIGHT_POINT, adminPanel.dkpHistoryBtn, Const.TOP_RIGHT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.optionsButton, "DKP Options", "Manage costs and gains", function()
        View:HideDKPAdjustFrame();
        View:HideDKPAdminsFrame();
        View:HideDKPHistoryFrame();
        View:HideAddGuildFrame();
        View:HideStandbysFrame();
        View:ToggleOptionsFrame();
    end)

    adminPanel.standbysButton = CreateTdkpMainFrameButton("Standbys", Const.BOTTOM_RIGHT_POINT, adminPanel.optionsButton, Const.TOP_RIGHT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.standbysButton, "Manage raid standbys", "Members added to the standby list will also recieve auto awarded DKP.", function()
        View:HideDKPAdjustFrame();
        View:HideOptionsFrame();
        View:HideDKPAdminsFrame();
        View:HideDKPHistoryFrame();
        View:HideAddGuildFrame();
        View:ToggleStandbysFrame();
    end)

    adminPanel.dkpAdjustBtn = CreateTdkpMainFrameButton("Adjust", Const.BOTTOM_RIGHT_POINT, adminPanel.standbysButton, Const.TOP_RIGHT_POINT, 0, 0)
    View:AttachHoverOverTooltipAndOnclick(adminPanel.dkpAdjustBtn, "DKP Adjustments", "Give on-time and raid completion bonuses.\nManually adjust player DKP.\nApply DKP Decay for guild.", function()
        View:HideOptionsFrame();
        View:HideDKPAdminsFrame()
        View:HideDKPHistoryFrame();
        View:HideAddGuildFrame();
        View:HideStandbysFrame();
        View:ToggleDKPAdjustFrame();
    end)

    adminPanel.dkpHeader = adminPanel:CreateFontString(nil, Const.OVERLAY_LAYER);
    adminPanel.dkpHeader:SetFontObject("ThirtyDKPSmall");
    adminPanel.dkpHeader:SetPoint(Const.BOTTOM_LEFT_POINT, adminPanel.dkpAdjustBtn, Const.TOP_LEFT_POINT, 0, 5);
    adminPanel.dkpHeader:SetSize(80, Const.ButtonHeight);
    adminPanel.dkpHeader:SetText("DKP")

end


local function CreateTdkpMainFrame(isAddonAdmin)
    local mainFrameWidth;
    if isAddonAdmin then
        mainFrameWidth = Const.DKPTableWidth + 130 -- make room for options buttons
    else
        mainFrameWidth = Const.DKPTableWidth + 40
    end
    

    TdkpMainFrame = View:CreateContainerFrame('ThirtyDKP_MainFrame', nil, TDKP_MAIN_FRAME_TITLE, mainFrameWidth, Const.DKPTableRowHeight*14);
    local f = TdkpMainFrame
	f:SetClampedToScreen(true);
	if isAddonAdmin then
		f:SetSize(420, 400);
	else
		f:SetSize(335, 400);
	end
	f:SetMovable(true);
	f:EnableMouse(true);
	f:RegisterForDrag("LeftButton");
	f:SetScript("OnDragStart", f.StartMoving);
	f:SetScript("OnDragStop", f.StopMovingOrSizing);
    f:SetScript("OnHide", function(self)
        if isAddonAdmin then
            View:HideOptionsFrame();
            View:HideDKPAdjustFrame();
            View:HideDKPHistoryFrame();
            View:HideDKPAdminsFrame()
        end
	end);


    -- up-to-date frame
    f.upToDateFrame = CreateFrame('Button', nil, f);
    f.upToDateFrame:SetSize(70, 15);
    f.upToDateFrame:SetPoint(Const.TOP_LEFT_POINT, ThirtyDKP_MainFrame, Const.TOP_LEFT_POINT, 110, -5);
    f.upToDateFrame:RegisterForClicks("AnyUp");
    f.upToDateFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    f.upToDateFrame:GetHighlightTexture():SetAlpha(0.5)
    f.upToDateFrame.text = f.upToDateFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	f.upToDateFrame.text:SetFontObject("ThirtyDKPTiny");
    f.upToDateFrame.text:SetPoint(Const.LEFT_POINT, f.upToDateFrame, Const.LEFT_POINT, 5, 0);
    
    View:UpdateDataUpToDateFrame()

    if isAddonAdmin then
        CreateRightSideAdminPanel();
    end
end

function View:GetMainFrame()
	return TdkpMainFrame;
end

function View:OpenMainFrame()
    View:UpdateDKPTable(true)
	TdkpMainFrame:SetShown(true);
end

function View:IsInitialized()
	return TdkpIsInitialized;
end

function View:Initialize()
    if TdkpIsInitialized then return end
    
    local isAddonAdmin = Core:IsAddonAdmin();

	CreateTdkpMainFrame(isAddonAdmin);
    View:CreateDKPTable(TdkpMainFrame);
    View:CreateBidAnnounceFrame();
    if isAddonAdmin then
        View:CreateOptionsFrame(TdkpMainFrame);
		View:CreateDKPAdjustFrame(TdkpMainFrame);
        View:CreateDKPAdminsFrame(TdkpMainFrame);
        View:CreateDKPHistoryFrame(TdkpMainFrame);
        View:CreateAddGuildFrame(TdkpMainFrame);
        View:CreateStandbysFrame(TdkpMainFrame);
    end

	TdkpIsInitialized = true;
end
