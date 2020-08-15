local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local RaidManagementFrame = nil;

local RAID_FRAME_TITLE = "Raid";
local RAID_BUTTON_START = "Start Raid";
local RAID_BUTTON_END = "End Raid";
local ADJUST_DKP_LABEL = "Adjust DKP";
local ADJUST_DKP_REASON_LABEL = "Reason";

local DkpAdjustReason = "";
local DkpAdjustAmount = 0;

function View:CreateRaidManagementFrame(parentFrame)
	RaidManagementFrame = CreateFrame("Frame", "ThirtyDKP_OptionsRaidManagementFrame", parentFrame, "TooltipBorderedFrameTemplate");
	RaidManagementFrame:SetShown(false);
	RaidManagementFrame:SetSize(370, 375);
	RaidManagementFrame:SetFrameStrata("HIGH");
	RaidManagementFrame:SetPoint(Const.TOP_LEFT_POINT, parentFrame, Const.TOP_RIGHT_POINT, 0, 0);
    RaidManagementFrame:EnableMouse(true);

    -- title
    local title = RaidManagementFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
    title:SetFontObject("GameFontNormal");
    title:SetPoint(Const.TOP_LEFT_POINT, RaidManagementFrame, Const.TOP_LEFT_POINT, 15, -10);
    title:SetText(RAID_FRAME_TITLE);

	-- Buttons
	local closeBtn = CreateFrame("Button", nil, RaidManagementFrame, "UIPanelCloseButton")
	closeBtn:SetPoint(Const.TOP_RIGHT_POINT, RaidManagementFrame, Const.TOP_RIGHT_POINT)

	local raidInfo = DAL:GetRaid();

	local startOrEndRaidBtn = CreateFrame("Button", nil, RaidManagementFrame, "GameMenuButtonTemplate");
	startOrEndRaidBtn:SetSize(100, 45);
	startOrEndRaidBtn:SetPoint(Const.TOP_LEFT_POINT, RaidManagementFrame, Const.TOP_LEFT_POINT, 10, -35);

	local onTimeBonusButton = CreateFrame("CheckButton", "onTimeBonusButton", RaidManagementFrame, "ChatConfigCheckButtonTemplate");
	onTimeBonusButton:SetPoint(Const.TOP_LEFT_POINT, startOrEndRaidBtn, Const.TOP_RIGHT_POINT, 10, 0);
	onTimeBonusButtonText:SetText("Give on-time bonus");
	onTimeBonusButton:SetChecked(true);

	local raidEndBonusButton = CreateFrame("CheckButton", "raidEndBonusButton", RaidManagementFrame, "ChatConfigCheckButtonTemplate");
	raidEndBonusButton:SetPoint(Const.TOP_LEFT_POINT, onTimeBonusButton, Const.BOTTOM_LEFT_POINT, 0, 0);
	raidEndBonusButton:SetChecked(true);
	raidEndBonusButtonText:SetText("Give raid completion bonus");

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

			if onTimeBonusButton:GetChecked() then
				Core:ApplyOnTimeBonus();
			end
		else
			Core:EndRaid();
			startOrEndRaidBtn:SetText(RAID_BUTTON_START);

			if raidEndBonusButton:GetChecked() then
				Core:ApplyRaidEndBonus();
			end
		end
	end);

	local adjustDkpSection = CreateFrame("Frame", nil, RaidManagementFrame, nil);
	adjustDkpSection:SetSize(RaidManagementFrame:GetWidth() - 25, 70);
	adjustDkpSection:SetPoint(Const.TOP_LEFT_POINT, startOrEndRaidBtn, Const.BOTTOM_LEFT_POINT, 0, -10);

    local adjustDkpLabel = adjustDkpSection:CreateFontString(nil, Const.OVERLAY_LAYER);
    adjustDkpLabel:SetFontObject("GameFontWhite");
    adjustDkpLabel:SetPoint(Const.TOP_LEFT_POINT, adjustDkpSection, Const.TOP_LEFT_POINT, 0, -25);
    adjustDkpLabel:SetText(ADJUST_DKP_LABEL);


	local reasonInput = View:CreateTextInputFrame(adjustDkpSection, "Reason:", "", function(input)
		DkpAdjustReason = input:GetText();
	end);
	reasonInput:SetPoint(Const.TOP_LEFT_POINT, adjustDkpLabel, Const.BOTTOM_LEFT_POINT, 0, -10);

	local amountWrapper = CreateFrame("Frame", nil, RaidManagementFrame, nil);
	amountWrapper:SetSize(130, 20);
	amountWrapper:SetPoint(Const.TOP_LEFT_POINT, reasonInput, BOTTOM_LEFT_POINT, 0, 0);
	local amountInput = View:CreateTextInputFrame(amountWrapper, "Amount:", 0, function(input)
		local text = input:GetText();
		if not text:match("^-?%d*$") then
			if #text == 1 then
				input:SetText("");
			else
				input:SetText(text:sub(0, #text - 1));
			end
		elseif #text > 0 then
			DkpAdjustAmount = tonumber(input:GetText());
		end
	end);
	amountInput:SetPoint(Const.TOP_LEFT_POINT, reasonInput, Const.BOTTOM_LEFT_POINT, 0, 0);

	local dkpAdjustBtn = CreateFrame("Button", nil, RaidManagementFrame, "GameMenuButtonTemplate");
	dkpAdjustBtn:SetSize(100, 30);
	dkpAdjustBtn:SetPoint(Const.TOP_LEFT_POINT, amountInput, Const.BOTTOM_LEFT_POINT, 0, -10);
	dkpAdjustBtn:SetText("Adjust");
	dkpAdjustBtn:SetNormalFontObject("GameFontNormal");
	dkpAdjustBtn:SetHighlightFontObject("GameFontHighlight");
	dkpAdjustBtn:RegisterForClicks("AnyUp");
	dkpAdjustBtn:SetScript("OnClick", function (self, button, down)
		if #DkpAdjustReason == 0 then
			Core:Print("No reason given");
			return;
		end

		if DkpAdjustAmount == 0 then
			Core:Print("No amount given");
			return;
		end

		local selectedPlayers = View:GetSelectedDKPTableEntries();

		if #selectedPlayers == 0 then
			Core:Print("No players selected");
			return;
		end

		StaticPopupDialogs["ADJUST_DKP"] = {
			text = "Are you you want to award "..DkpAdjustAmount.." DKP?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function()
				Core:AdjustPlayersDKP(selectedPlayers, DkpAdjustAmount, DkpAdjustReason)
				amountInput.input:SetText("");
				reasonInput.input:SetText("");
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("ADJUST_DKP");
	end);

	local applyDecayBtn = CreateFrame("Button", nil, RaidManagementFrame, "GameMenuButtonTemplate");
	applyDecayBtn:SetSize(100, 30);
	applyDecayBtn:SetPoint(Const.TOP_LEFT_POINT, dkpAdjustBtn, Const.BOTTOM_LEFT_POINT, 0, -10);
	applyDecayBtn:SetText("Apply Decay");
	applyDecayBtn:SetNormalFontObject("GameFontNormal");
	applyDecayBtn:SetHighlightFontObject("GameFontHighlight");
	applyDecayBtn:RegisterForClicks("AnyUp");
	applyDecayBtn:SetScript("OnClick", function (self, button, down)
		StaticPopupDialogs["APPLY_DECAY"] = {
			text = "Are you sure you want to apply decay?",
			button1 = "Yes",
			button2 = "No",
			OnAccept = function()
				Core:ApplyDecay();
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3,
		}
		StaticPopup_Show("APPLY_DECAY");

	end);

end

function View:ToggleRaidManagementFrame()
    RaidManagementFrame:SetShown(not RaidManagementFrame:IsShown());
end

function View:HideRaidManagementFrame()
    RaidManagementFrame:SetShown(false);
end
