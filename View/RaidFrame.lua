local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local RaidFrame = nil;

local RAID_FRAME_TITLE = "Raid";
local RAID_BUTTON_START = "Start Raid";
local RAID_BUTTON_END = "End Raid";

function View:CreateRaidFrame(parentFrame)
	RaidFrame = CreateFrame("Frame", "ThirtyDKP_OptionsFrame", parentFrame, "TooltipBorderedFrameTemplate");
	RaidFrame:SetShown(false);
	RaidFrame:SetSize(370, 375);
	RaidFrame:SetFrameStrata("HIGH");
	RaidFrame:SetPoint(Const.TOP_LEFT_POINT, parentFrame, Const.TOP_RIGHT_POINT, 0, 0);
    RaidFrame:EnableMouse(true);

    -- title
    local title = RaidFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
    title:SetFontObject("GameFontNormal");
    title:SetPoint(Const.TOP_LEFT_POINT, RaidFrame, Const.TOP_LEFT_POINT, 15, -10);
    title:SetText(RAID_FRAME_TITLE);

	-- Buttons
	local closeBtn = CreateFrame("Button", nil, RaidFrame, "UIPanelCloseButton")
	closeBtn:SetPoint(Const.TOP_RIGHT_POINT, RaidFrame, Const.TOP_RIGHT_POINT)

	local raidInfo = DAL:GetRaid();

	local startOrEndRaidBtn = CreateFrame("Button", nil, RaidFrame, "GameMenuButtonTemplate");
	startOrEndRaidBtn:SetSize(100, 30);
	startOrEndRaidBtn:SetPoint(Const.TOP_LEFT_POINT, RaidFrame, Const.TOP_LEFT_POINT, 10, -35);

	if raidInfo.raidOngoing then
		startOrEndRaidBtn:SetText(RAID_BUTTON_END);
	else
		startOrEndRaidBtn:SetText(RAID_BUTTON_START);
	end
	startOrEndRaidBtn:SetNormalFontObject("GameFontNormal");
	startOrEndRaidBtn:SetHighlightFontObject("GameFontHighlight");
	startOrEndRaidBtn:RegisterForClicks("AnyUp");
	startOrEndRaidBtn:SetScript("OnClick", function (self, button, down)
		if not Core:IsPlayerMasterLooter() then
			StaticPopupDialogs["STARTEND_RAID"] = {
				text = "You must be master looter to start or end raids",
				button1 = "OK",
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("STARTEND_RAID");
			return;
		end
		if self:GetText() == RAID_BUTTON_START then
			Core:StartRaid();
			startOrEndRaidBtn:SetText(RAID_BUTTON_END);
		else
			Core:EndRaid();
			startOrEndRaidBtn:SetText(RAID_BUTTON_START);
		end
	end);

	local applyDecayBtn = CreateFrame("Button", nil, RaidFrame, "GameMenuButtonTemplate");
	applyDecayBtn:SetSize(100, 30);
	applyDecayBtn:SetPoint(Const.TOP_LEFT_POINT, startOrEndRaidBtn, Const.BOTTOM_LEFT_POINT, 0, 0);
	applyDecayBtn:SetText("Apply Decay");
	applyDecayBtn:SetNormalFontObject("GameFontNormal");
	applyDecayBtn:SetHighlightFontObject("GameFontHighlight");
	applyDecayBtn:RegisterForClicks("AnyUp");
	applyDecayBtn:SetScript("OnClick", function (self, button, down)
	end);
end

function View:ToggleRaidFrame()
    RaidFrame:SetShown(not RaidFrame:IsShown());
end

function View:HideRaidFrame()
    RaidFrame:SetShown(false);
end
