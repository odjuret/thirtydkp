local addonName, ThirtyDKP = ...
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local OptionsFrame = nil;

local OPTIONS_FRAME_TITLE = "Options"


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

function View:CreateOptionsFrame(parentFrame)
	OptionsFrame = CreateFrame('Frame', 'ThirtyDKP_OptionsFrame', UIParent, "UIPanelDialogTemplate"); -- Todo: make mainframe owner??
	OptionsFrame:SetShown(false);
	OptionsFrame:SetSize(500, 500);
	OptionsFrame:SetFrameStrata("HIGH");
	OptionsFrame:SetClampedToScreen(true);
	OptionsFrame:SetPoint(Const.TOP_LEFT_POINT, parentFrame, Const.TOP_RIGHT_POINT, 0, 0); -- point, relative frame, relative point on relative frame
	OptionsFrame:EnableMouse(true);

    -- title
    local title = OptionsFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
    title:SetFontObject("GameFontNormal");
    title:ClearAllPoints();
    title:SetPoint(Const.TOP_LEFT_POINT, OptionsFrame, Const.TOP_LEFT_POINT, 15, -10);
    title:SetText(OPTIONS_FRAME_TITLE);

    -- Buttons
    OptionsFrame.addRaidToTableBtn = CreateFrame("Button", nil, OptionsFrame, "GameMenuButtonTemplate");
    OptionsFrame.addRaidToTableBtn:SetPoint(Const.BOTTOMLEFT_POINT, OptionsFrame, Const.BOTTOMLEFT_POINT, 10, 10);
    OptionsFrame.addRaidToTableBtn:SetSize(80, 30);
    OptionsFrame.addRaidToTableBtn:SetText("Add Raid");
    OptionsFrame.addRaidToTableBtn:SetNormalFontObject("GameFontNormal");
    OptionsFrame.addRaidToTableBtn:SetHighlightFontObject("GameFontHighlight");
    OptionsFrame.addRaidToTableBtn:RegisterForClicks("AnyUp");
    
    AttachAddRaidToTableScripts(OptionsFrame.addRaidToTableBtn)

	 -- Add
	OptionsFrame.addGuildToTableBtn = CreateFrame("Button", nil, OptionsFrame, "GameMenuButtonTemplate");
	OptionsFrame.addGuildToTableBtn:SetPoint(Const.BOTTOMLEFT_POINT, OptionsFrame, Const.BOTTOMLEFT_POINT, 90, 10);
	OptionsFrame.addGuildToTableBtn:SetSize(80, 30);
	OptionsFrame.addGuildToTableBtn:SetText("Add Guild");
	OptionsFrame.addGuildToTableBtn:SetNormalFontObject("GameFontNormal");
	OptionsFrame.addGuildToTableBtn:SetHighlightFontObject("GameFontHighlight");
	OptionsFrame.addGuildToTableBtn:RegisterForClicks("AnyUp");

	AttachAddGuildToTableScript(OptionsFrame.addGuildToTableBtn);
end

function View:ToggleOptionsFrame()
    OptionsFrame:SetShown(not OptionsFrame:IsShown());
end

function View:HideOptionsFrame()
    OptionsFrame:SetShown(false);
end