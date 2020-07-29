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


local function AttachAddRaidToTableScripts(frame)
    -- add raid to dkp table if they don't exist

	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("Add raid members to DKP table", 0.25, 0.75, 0.90, 1, true);
		GameTooltip:AddLine("Given that theyre in the guild obviously", 1.0, 1.0, 1.0, true);
		GameTooltip:Show();
	end)
	frame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
    frame:SetScript("OnClick", function ()
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

local function AttachAddGuildToTableScript(frame)
    -- add guild to dkp table if entry doesn't exist

    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText("Add guild members to DKP table", 0.25, 0.75, 0.90, 1, true);
        GameTooltip:AddLine("Adds guild members that aren't in the dkp table", 1.0, 1.0, 1.0, true);
        GameTooltip:Show();
    end);

    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end);

    frame:SetScript("OnClick", function ()
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

local function AttachBroadcastDKPTableScript(frame)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText("Broadcasts ThirtyDKP data", 0.25, 0.75, 0.90, 1, true);
        GameTooltip:AddLine("Attempts to broadcast out the latest ThirtyDKP data to other online members:", 1.0, 1.0, 1.0, true);
        GameTooltip:AddLine("dkp table, dkp history and addon options", 1.0, 1.0, 1.0, true);
        GameTooltip:Show();
    end);

    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end);

    frame:SetScript("OnClick", function ()
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
    end);
end


local function AttachRaidScript(frame)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText("Raid Management", 0.25, 0.75, 0.90, 1, true);
        GameTooltip:AddLine("Manage raids and handle manual DKP adjustments", 1.0, 1.0, 1.0, true);
        GameTooltip:Show();
    end);

	frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end);

	frame:SetScript("OnClick", function()
        View:HideOptionsFrame();
        View:HideTdkpAdminsFrame()
        View:HideDKPHistoryFrame();
		View:ToggleRaidFrame();
	end);
end

local function AttachDKPAdminsBtnScripts(frame)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText("Admins Management", 0.25, 0.75, 0.90, 1, true);
        GameTooltip:AddLine("Manage DKP admins for your guild. Admins can change dkp options, adjust dkp, start dkp awarding raids, etc", 1.0, 1.0, 1.0, true);
        GameTooltip:Show();
    end);

	frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end);

    frame:SetScript("OnClick", function()
        View:HideOptionsFrame();
        View:HideRaidFrame();
        View:HideDKPHistoryFrame();
        View:ToggleTdkpAdminsFrame()
	end);
end


local function AttachDKPHistoryBtnScripts(frame)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText("DKP History", 0.25, 0.75, 0.90, 1, true);
        GameTooltip:AddLine("Manage DKP history for your guild.", 1.0, 1.0, 1.0, true);
        GameTooltip:Show();
    end);

	frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end);

    frame:SetScript("OnClick", function()
        View:HideOptionsFrame();
        View:HideRaidFrame();
        View:HideTdkpAdminsFrame()
        View:ToggleDKPHistoryFrame();
	end);
end

local function CreateMainFrame(isAddonAdmin)
    local mainFrameWidth;
    if isAddonAdmin then
        mainFrameWidth = Const.DKPTableWidth + 130 -- make room for options buttons
    else
        mainFrameWidth = Const.DKPTableWidth + 40
    end
    

	MainFrame = CreateFrame('Frame', 'ThirtyDKP_MainFrame', UIParent, "TooltipBorderedFrameTemplate");
	MainFrame:SetShown(false);
    MainFrame:SetSize(mainFrameWidth, Const.DKPTableRowHeight*14); -- width, height
	MainFrame:SetPoint(Const.CENTER_POINT, UIParent, Const.CENTER_POINT, 0, 60); -- point, relative frame, relative point on relative frame
	MainFrame:SetFrameStrata("HIGH");
    MainFrame:SetFrameLevel(8);
    MainFrame:SetBackdropColor(0,0,0,.1)
    MainFrame:SetBackdropBorderColor(0,0,0,.1)

	tinsert(UISpecialFrames, MainFrame:GetName()); -- Sets frame to close on "Escape"

	MainFrame:SetClampedToScreen(true);
	MainFrame:SetMovable(true);
	MainFrame:EnableMouse(true);
	MainFrame:RegisterForDrag("LeftButton");
	MainFrame:SetScript("OnDragStart", MainFrame.StartMoving);
	MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing);
    MainFrame:SetScript("OnHide", function(self)
        if isAddonAdmin then
            View:HideOptionsFrame();
            View:HideRaidFrame();
        end
	end);

    -- title
    MainFrame.Title = MainFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	MainFrame.Title:SetFontObject("GameFontNormal");
    MainFrame.Title:SetPoint(Const.TOP_LEFT_POINT, ThirtyDKP_MainFrame, Const.TOP_LEFT_POINT, Const.Margin, -10);
    MainFrame.Title:SetText(MAIN_FRAME_TITLE);

	-- Buttons
	MainFrame.closeBtn = CreateFrame("Button", nil, MainFrame, "UIPanelCloseButton")
	MainFrame.closeBtn:SetPoint(Const.TOP_RIGHT_POINT, MainFrame, Const.TOP_RIGHT_POINT)


    if isAddonAdmin then
        MainFrame.optionsButton = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
        MainFrame.optionsButton:SetPoint(Const.BOTTOM_RIGHT_POINT, MainFrame, Const.BOTTOM_RIGHT_POINT, -10, 10);
        MainFrame.optionsButton:SetSize(80, Const.ButtonHeight);
        MainFrame.optionsButton:SetText("Options");
        MainFrame.optionsButton:SetNormalFontObject("GameFontNormal");
        MainFrame.optionsButton:SetHighlightFontObject("GameFontHighlight");
        MainFrame.optionsButton:RegisterForClicks("AnyUp");
        MainFrame.optionsButton:SetScript("OnClick", function (self, button, down)
            View:HideRaidFrame();
            View:HideTdkpAdminsFrame();
            View:ToggleOptionsFrame();
        end);


        --  add raid to dkp table button
        MainFrame.addRaidToTableBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
        MainFrame.addRaidToTableBtn:SetPoint(Const.BOTTOM_LEFT_POINT, MainFrame.optionsButton, Const.TOP_LEFT_POINT, 0, 0);
        MainFrame.addRaidToTableBtn:SetSize(80, Const.ButtonHeight);
        MainFrame.addRaidToTableBtn:SetText("Add Raid");
        MainFrame.addRaidToTableBtn:SetNormalFontObject("GameFontNormal");
        MainFrame.addRaidToTableBtn:SetHighlightFontObject("GameFontHighlight");
        MainFrame.addRaidToTableBtn:RegisterForClicks("AnyUp");

        AttachAddRaidToTableScripts(MainFrame.addRaidToTableBtn)


        --  add guild to dkp table button
        MainFrame.addGuildToTableBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
        MainFrame.addGuildToTableBtn:SetPoint(Const.BOTTOM_LEFT_POINT, MainFrame.addRaidToTableBtn, Const.TOP_LEFT_POINT, 0, 0);
        MainFrame.addGuildToTableBtn:SetSize(80, Const.ButtonHeight);
        MainFrame.addGuildToTableBtn:SetText("Add Guild");
        MainFrame.addGuildToTableBtn:SetNormalFontObject("GameFontNormal");
        MainFrame.addGuildToTableBtn:SetHighlightFontObject("GameFontHighlight");
        MainFrame.addGuildToTableBtn:RegisterForClicks("AnyUp");

        AttachAddGuildToTableScript(MainFrame.addGuildToTableBtn);


        --  broadcast dkp table to online members button
        MainFrame.broadcastBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
        MainFrame.broadcastBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, MainFrame.addGuildToTableBtn, Const.TOP_RIGHT_POINT, 0, 0);
        MainFrame.broadcastBtn:SetSize(80, Const.ButtonHeight);
        MainFrame.broadcastBtn:SetText("Broadcast");
        MainFrame.broadcastBtn:SetNormalFontObject("GameFontNormal");
        MainFrame.broadcastBtn:SetHighlightFontObject("GameFontHighlight");
        MainFrame.broadcastBtn:RegisterForClicks("AnyUp");

        AttachBroadcastDKPTableScript(MainFrame.broadcastBtn);


        -- raid management button
		MainFrame.raidBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
        MainFrame.raidBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, MainFrame.broadcastBtn, Const.TOP_RIGHT_POINT, 0, 0);
        MainFrame.raidBtn:SetSize(80, Const.ButtonHeight);
        MainFrame.raidBtn:SetText("Raid");
        MainFrame.raidBtn:SetNormalFontObject("GameFontNormal");
        MainFrame.raidBtn:SetHighlightFontObject("GameFontHighlight");
        MainFrame.raidBtn:RegisterForClicks("AnyUp");

        AttachRaidScript(MainFrame.raidBtn);
        

        -- dkp admins button
        MainFrame.dkpAdminsBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
        MainFrame.dkpAdminsBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, MainFrame.raidBtn, Const.TOP_RIGHT_POINT, 0, 0);
        MainFrame.dkpAdminsBtn:SetSize(80, Const.ButtonHeight);
        MainFrame.dkpAdminsBtn:SetText("Admins");
        MainFrame.dkpAdminsBtn:SetNormalFontObject("GameFontNormal");
        MainFrame.dkpAdminsBtn:SetHighlightFontObject("GameFontHighlight");
        MainFrame.dkpAdminsBtn:RegisterForClicks("AnyUp");

        AttachDKPAdminsBtnScripts(MainFrame.dkpAdminsBtn);


        -- dkp history button
        MainFrame.dkpHistoryBtn = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
        MainFrame.dkpHistoryBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, MainFrame.dkpAdminsBtn, Const.TOP_RIGHT_POINT, 0, 0);
        MainFrame.dkpHistoryBtn:SetSize(80, Const.ButtonHeight);
        MainFrame.dkpHistoryBtn:SetText("History");
        MainFrame.dkpHistoryBtn:SetNormalFontObject("GameFontNormal");
        MainFrame.dkpHistoryBtn:SetHighlightFontObject("GameFontHighlight");
        MainFrame.dkpHistoryBtn:RegisterForClicks("AnyUp");

        AttachDKPHistoryBtnScripts(MainFrame.dkpHistoryBtn);
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
		View:CreateRaidFrame(MainFrame);
        View:CreateTdkpAdminsFrame(MainFrame);
        View:CreateDKPHistoryFrame(MainFrame);
    end

	Initialized = true;
end
