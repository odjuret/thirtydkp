local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local DKPAdjustFrame = nil;

local DKPADJUST_FRAME_TITLE = "DKP Adjustments";
local TDKP_RAID_BUTTON_START = "Start Raid";
local TDKP_RAID_BUTTON_END = "End Raid";
local ADJUST_DKP_LABEL = "Adjust DKP";
local ADJUST_DKP_REASON_LABEL = "Reason";

local DkpAdjustReason = "";
local DkpAdjustAmount = 0;

function View:CreateDKPAdjustFrame(parentFrame)
	DKPAdjustFrame = View:CreateContainerFrame("ThirtyDKP_DKPAdjustFrame", parentFrame, DKPADJUST_FRAME_TITLE, 370, 300);

	local raidInfo = DAL:GetRaid();

	local startOrEndRaidBtn = CreateFrame("Button", nil, DKPAdjustFrame, "GameMenuButtonTemplate");
	startOrEndRaidBtn:SetSize(100, 30);
	startOrEndRaidBtn:SetPoint(Const.TOP_LEFT_POINT, DKPAdjustFrame, Const.TOP_LEFT_POINT, 10, -35);

	local onTimeBonusButton = CreateFrame("CheckButton", "onTimeBonusButton", DKPAdjustFrame, "ChatConfigCheckButtonTemplate");
	onTimeBonusButton:SetPoint(Const.TOP_LEFT_POINT, startOrEndRaidBtn, Const.TOP_RIGHT_POINT, 10, 0);
	onTimeBonusButtonText:SetText("Give on-time bonus");
	onTimeBonusButton:SetChecked(true);

	local raidEndBonusButton = CreateFrame("CheckButton", "raidEndBonusButton", DKPAdjustFrame, "ChatConfigCheckButtonTemplate");
	raidEndBonusButton:SetPoint(Const.TOP_LEFT_POINT, onTimeBonusButton, Const.BOTTOM_LEFT_POINT, 0, 0);
	raidEndBonusButton:SetChecked(true);
	raidEndBonusButtonText:SetText("Give raid completion bonus");

	if raidInfo.raidOngoing then
		startOrEndRaidBtn:SetText(TDKP_RAID_BUTTON_END);
	else
		startOrEndRaidBtn:SetText(TDKP_RAID_BUTTON_START);
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
		if self:GetText() == TDKP_RAID_BUTTON_START then
			Core:StartRaid();
			startOrEndRaidBtn:SetText(TDKP_RAID_BUTTON_END);

			if onTimeBonusButton:GetChecked() then
				Core:ApplyOnTimeBonus();
			end
		else
			Core:EndRaid();
			startOrEndRaidBtn:SetText(TDKP_RAID_BUTTON_START);

			if raidEndBonusButton:GetChecked() then
				Core:ApplyRaidEndBonus();
			end
		end
	end);

	local adjustDkpSection = CreateFrame("Frame", nil, DKPAdjustFrame, nil);
	adjustDkpSection:SetSize(DKPAdjustFrame:GetWidth() - 50, 70);
	adjustDkpSection:SetPoint(Const.TOP_LEFT_POINT, startOrEndRaidBtn, Const.BOTTOM_LEFT_POINT, 0, -10);

    local adjustDkpLabel = adjustDkpSection:CreateFontString(nil, Const.OVERLAY_LAYER);
    adjustDkpLabel:SetFontObject("GameFontWhite");
    adjustDkpLabel:SetPoint(Const.TOP_LEFT_POINT, adjustDkpSection, Const.TOP_LEFT_POINT, 0, -25);
    adjustDkpLabel:SetText(ADJUST_DKP_LABEL);


	local reasonInput = View:CreateTextInputFrame(adjustDkpSection, "Reason: ", "", function(input)
		DkpAdjustReason = input:GetText();
	end);
	reasonInput:SetPoint(Const.TOP_LEFT_POINT, adjustDkpLabel, Const.BOTTOM_LEFT_POINT, 0, -10);

	local amountWrapper = CreateFrame("Frame", nil, DKPAdjustFrame, nil);
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

	local dkpAdjustBtn = CreateFrame("Button", nil, DKPAdjustFrame, "GameMenuButtonTemplate");
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

	local applyDecayBtn = CreateFrame("Button", nil, DKPAdjustFrame, "GameMenuButtonTemplate");
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

function View:ToggleDKPAdjustFrame()
    DKPAdjustFrame:SetShown(not DKPAdjustFrame:IsShown());
end

function View:HideDKPAdjustFrame()
    DKPAdjustFrame:SetShown(false);
end
