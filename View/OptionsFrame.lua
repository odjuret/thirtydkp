local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local TdkpOptionsFrame = nil;

local TDKP_OPTIONS_FRAME_TITLE = "Options"

local SelectedRaid = Const.RAID_NAXX;


local function CreateDkpCostInputFrame(text, itemName, parent)
    local options = DAL:GetRaidOptions(SelectedRaid);
    local inputFrame = View:CreateNumericInputFrame(parent, text, options.itemCosts[itemName], function(input)
		DAL:GetRaidOptions(SelectedRaid).itemCosts[itemName] = input:GetNumber();
    end);

    return inputFrame;
end

local function CreateAndAttachDkpCostFrame(text, itemName, parent, attachTarget)
    local inputFrame = CreateDkpCostInputFrame(text, itemName, parent);
    inputFrame:SetPoint(Const.TOP_LEFT_POINT, attachTarget, Const.BOTTOM_LEFT_POINT, 0, 0);
    return inputFrame;
end

function View:UpdateOptionsFrame()
	SelectedRaid = DAL:GetLastSelectedRaid();
	local options = DAL:GetRaidOptions(SelectedRaid);
	local decayOption, onTimeOption, CompletionBonusOption = DAL:GetGlobalDKPOptions();

	TdkpOptionsFrame.onTimeBonus.input:SetNumber(onTimeOption);
	TdkpOptionsFrame.raidCompletionBonus.input:SetNumber(CompletionBonusOption);
	TdkpOptionsFrame.decay.input:SetNumber(decayOption);
	
	TdkpOptionsFrame.dkpGainPerKill.input:SetNumber(options.dkpGainPerKill);
	TdkpOptionsFrame.headCostInput.input:SetNumber(options.itemCosts.head);
	TdkpOptionsFrame.neckCostInput.input:SetNumber(options.itemCosts.neck);
	TdkpOptionsFrame.shouldersCostInput.input:SetNumber(options.itemCosts.shoulders);
	TdkpOptionsFrame.backCostInput.input:SetNumber(options.itemCosts.back);
	TdkpOptionsFrame.chestCostInput.input:SetNumber(options.itemCosts.chest);
	TdkpOptionsFrame.bracersCostInput.input:SetNumber(options.itemCosts.bracers);
	TdkpOptionsFrame.glovesCostInput.input:SetNumber(options.itemCosts.gloves);
	TdkpOptionsFrame.beltCostInput.input:SetNumber(options.itemCosts.belt);
	TdkpOptionsFrame.legsCostInput.input:SetNumber(options.itemCosts.legs);
	TdkpOptionsFrame.bootsCostInput.input:SetNumber(options.itemCosts.boots);
	TdkpOptionsFrame.ringCostInput.input:SetNumber(options.itemCosts.ring);
	TdkpOptionsFrame.trinketCostInput.input:SetNumber(options.itemCosts.trinket);
	TdkpOptionsFrame.oneHandedWeaponCostInput.input:SetNumber(options.itemCosts.oneHandedWeapon);
	TdkpOptionsFrame.twoHandedWeaponCostInput.input:SetNumber(options.itemCosts.twoHandedWeapon);
	TdkpOptionsFrame.rangedWeaponCostInput.input:SetNumber(options.itemCosts.rangedWeapon);
	TdkpOptionsFrame.defaultCostInput.input:SetNumber(options.itemCosts.default);
end

local function RaidDropdownOnClick(self, arg1, arg2, checked)
	SelectedRaid = arg1;
	DAL:SetLastSelectedRaid(arg1)
	L_UIDropDownMenu_SetText(TdkpOptionsFrame.raidDropdown, Const.RAID_DISPLAY_NAME[arg1]);
	View:UpdateOptionsFrame();
end

local function InitializeRaidDropdown(_, _, _)
	local raidDropdownInfo = L_UIDropDownMenu_CreateInfo();
	raidDropdownInfo.func = RaidDropdownOnClick;

	raidDropdownInfo.text = "Naxxramas";
	raidDropdownInfo.arg1 = Const.RAID_NAXX;
	raidDropdownInfo.arg2 = raidDropdownInfo.text;
	raidDropdownInfo.checked = SelectedRaid == Const.RAID_NAXX;
	L_UIDropDownMenu_AddButton(raidDropdownInfo);

	raidDropdownInfo.text = "Ahn'Qiraj";
	raidDropdownInfo.arg1 = Const.RAID_AQ40;
	raidDropdownInfo.arg2 = raidDropdownInfo.text;
	raidDropdownInfo.checked = SelectedRaid == Const.RAID_AQ40;
	L_UIDropDownMenu_AddButton(raidDropdownInfo);

	raidDropdownInfo.text = "Blackwing Lair";
	raidDropdownInfo.arg1 = Const.RAID_BWL;
	raidDropdownInfo.arg2 = raidDropdownInfo.text;
	raidDropdownInfo.checked = SelectedRaid == Const.RAID_BWL;
	L_UIDropDownMenu_AddButton(raidDropdownInfo);

	raidDropdownInfo.text = "Molten Core";
	raidDropdownInfo.arg1 = Const.RAID_MC;
	raidDropdownInfo.arg2 = raidDropdownInfo.text;
	raidDropdownInfo.checked = SelectedRaid == Const.RAID_MC;
	L_UIDropDownMenu_AddButton(raidDropdownInfo);

	raidDropdownInfo.text = "Onyxia";
	raidDropdownInfo.arg1 = Const.RAID_ONYXIA;
	raidDropdownInfo.arg2 = raidDropdownInfo.text;
	raidDropdownInfo.checked = selectedRaid == Const.RAID_ONYXIA;
	L_UIDropDownMenu_AddButton(raidDropdownInfo);
end

function View:CreateOptionsFrame(parentFrame)
	TdkpOptionsFrame = View:CreateContainerFrame("ThirtyDKP_OptionsFrame", parentFrame, TDKP_OPTIONS_FRAME_TITLE, 320, 440);

	local options = DAL:GetOptions();
	SelectedRaid = options.lastSelectedRaid
    local raidOptions = DAL:GetRaidOptions(SelectedRaid);

	local globalOptionsHeader = TdkpOptionsFrame:CreateFontString(nil, OVERLAY_LAYER);
	globalOptionsHeader:SetFontObject("GameFontNormal");
	globalOptionsHeader:SetPoint(Const.TOP_LEFT_POINT, TdkpOptionsFrame, Const.TOP_LEFT_POINT, 10, -35);
	globalOptionsHeader:SetText("Global Options");


    -- global settings, two sections
    local globalSectionLeft = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
    globalSectionLeft:SetSize(145, 70);
    globalSectionLeft:SetPoint(Const.TOP_LEFT_POINT, globalOptionsHeader, Const.BOTTOM_LEFT_POINT, 10, -10);

    local globalSectionRight = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
    globalSectionRight:SetSize(70, 70);
    globalSectionRight:SetPoint(Const.TOP_LEFT_POINT, globalSectionLeft, Const.TOP_RIGHT_POINT, 30, 0);

    TdkpOptionsFrame.onTimeBonus = View:CreateNumericInputFrame(globalSectionLeft, "On Time Bonus:", options.onTimeBonus, function(input)
        options.onTimeBonus = input:GetNumber();
    end);
	TdkpOptionsFrame.onTimeBonus:SetPoint(Const.TOP_LEFT_POINT, globalSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

	TdkpOptionsFrame.raidCompletionBonus = View:CreateNumericInputFrame(globalSectionLeft, "Raid Completion Bonus:", options.raidCompletionBonus, function(input)
        options.raidCompletionBonus = input:GetNumber();
    end);
	TdkpOptionsFrame.raidCompletionBonus:SetPoint(Const.TOP_LEFT_POINT, TdkpOptionsFrame.onTimeBonus, Const.BOTTOM_LEFT_POINT, 0, 0);

	TdkpOptionsFrame.decay = View:CreateNumericInputFrame(globalSectionRight, "Decay:", options.decay, function(input)
        options.decay = input:GetNumber();
    end);
	TdkpOptionsFrame.decay:SetPoint(Const.TOP_LEFT_POINT);
	local decayPercentageCharacter = globalSectionRight:CreateFontString(nil, OVERLAY_LAYER);
	decayPercentageCharacter:SetFontObject("ThirtyDKPSmall");
	decayPercentageCharacter:SetPoint(Const.TOP_LEFT_POINT, globalSectionRight, Const.TOP_RIGHT_POINT, 4, -2);
	decayPercentageCharacter:SetText("%");


	local raidOptionsHeader = TdkpOptionsFrame:CreateFontString(nil, OVERLAY_LAYER);
	raidOptionsHeader:SetFontObject("GameFontNormal");
	raidOptionsHeader:SetPoint(Const.TOP_LEFT_POINT, globalSectionLeft, Const.BOTTOM_LEFT_POINT, -10, 0);
	raidOptionsHeader:SetText("Raid Specific Options for: ");

	TdkpOptionsFrame.raidDropdown = CreateFrame("Frame", "ThirtyDKP_RaidOptionsDropdown", TdkpOptionsFrame, "L_UIDropDownMenuTemplate");
	TdkpOptionsFrame.raidDropdown:SetPoint(Const.LEFT_POINT, raidOptionsHeader, Const.RIGHT_POINT, 0, -4);
	L_UIDropDownMenu_SetWidth(TdkpOptionsFrame.raidDropdown, 110);
	L_UIDropDownMenu_Initialize(TdkpOptionsFrame.raidDropdown, InitializeRaidDropdown);
	L_UIDropDownMenu_SetText(TdkpOptionsFrame.raidDropdown, Const.RAID_DISPLAY_NAME[SelectedRaid]);


	local dkpGainSection = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
	dkpGainSection:SetSize(95, 30);
	dkpGainSection:SetPoint(Const.TOP_LEFT_POINT, raidOptionsHeader, Const.BOTTOM_LEFT_POINT, 10, -10);
	TdkpOptionsFrame.dkpGainPerKill = View:CreateNumericInputFrame(dkpGainSection, "Boss kill DKP:", raidOptions.dkpGainPerKill, function(input)
		DAL:GetRaidOptions(SelectedRaid).dkpGainPerKill = input:GetNumber();
    end);
    TdkpOptionsFrame.dkpGainPerKill:SetAllPoints();

	local itemCostHeader = TdkpOptionsFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	itemCostHeader:SetFontObject("GameFontNormal");
	itemCostHeader:SetPoint(Const.TOP_LEFT_POINT, dkpGainSection, Const.BOTTOM_LEFT_POINT, 0, -10);
	itemCostHeader:SetText("Item Costs");

    -- Item cost setting, two sections
    local itemCostSectionLeft = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
    itemCostSectionLeft:SetSize(85, 150);
    itemCostSectionLeft:SetPoint(Const.TOP_LEFT_POINT, itemCostHeader, Const.BOTTOM_LEFT_POINT, 10, -10);

    local itemCostSectionRight = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
    itemCostSectionRight:SetSize(95, 150);
    itemCostSectionRight:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionLeft, Const.TOP_RIGHT_POINT, 30, 0);

    -- Left section
    TdkpOptionsFrame.headCostInput = CreateDkpCostInputFrame("Head:", "head", itemCostSectionLeft);
    TdkpOptionsFrame.headCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

    TdkpOptionsFrame.neckCostInput = CreateAndAttachDkpCostFrame("Neck:", "neck", itemCostSectionLeft, TdkpOptionsFrame.headCostInput);
    TdkpOptionsFrame.shouldersCostInput = CreateAndAttachDkpCostFrame("Shoulders:", "shoulders", itemCostSectionLeft, TdkpOptionsFrame.neckCostInput);
    TdkpOptionsFrame.backCostInput = CreateAndAttachDkpCostFrame("Back:", "back", itemCostSectionLeft, TdkpOptionsFrame.shouldersCostInput);
    TdkpOptionsFrame.chestCostInput = CreateAndAttachDkpCostFrame("Chest:", "chest", itemCostSectionLeft, TdkpOptionsFrame.backCostInput);
    TdkpOptionsFrame.bracersCostInput = CreateAndAttachDkpCostFrame("Bracers:", "bracers", itemCostSectionLeft, TdkpOptionsFrame.chestCostInput);
    TdkpOptionsFrame.glovesCostInput = CreateAndAttachDkpCostFrame("Gloves:", "gloves", itemCostSectionLeft, TdkpOptionsFrame.bracersCostInput);
    TdkpOptionsFrame.beltCostInput = CreateAndAttachDkpCostFrame("Belt:", "belt", itemCostSectionLeft, TdkpOptionsFrame.glovesCostInput);
    TdkpOptionsFrame.legsCostInput = CreateAndAttachDkpCostFrame("Legs:", "legs", itemCostSectionLeft, TdkpOptionsFrame.beltCostInput);

    -- Right section
    TdkpOptionsFrame.bootsCostInput = CreateDkpCostInputFrame("Boots:", "boots", itemCostSectionRight);
    TdkpOptionsFrame.bootsCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionRight, Const.TOP_LEFT_POINT, 0, 0);
    TdkpOptionsFrame.ringCostInput = CreateAndAttachDkpCostFrame("Ring:", "ring", itemCostSectionRight, TdkpOptionsFrame.bootsCostInput);
    TdkpOptionsFrame.trinketCostInput = CreateAndAttachDkpCostFrame("Trinket:", "trinket", itemCostSectionRight, TdkpOptionsFrame.ringCostInput);
    TdkpOptionsFrame.oneHandedWeaponCostInput = CreateAndAttachDkpCostFrame("One-handed:", "oneHandedWeapon", itemCostSectionRight, TdkpOptionsFrame.trinketCostInput);
    TdkpOptionsFrame.twoHandedWeaponCostInput = CreateAndAttachDkpCostFrame("Two-handed:", "twoHandedWeapon", itemCostSectionRight, TdkpOptionsFrame.oneHandedWeaponCostInput);
    TdkpOptionsFrame.rangedWeaponCostInput = CreateAndAttachDkpCostFrame("Ranged:", "rangedWeapon", itemCostSectionRight, TdkpOptionsFrame.twoHandedWeaponCostInput);
    TdkpOptionsFrame.offhandCostInput = CreateAndAttachDkpCostFrame("Offhand:", "offhand", itemCostSectionRight, TdkpOptionsFrame.rangedWeaponCostInput);
    TdkpOptionsFrame.defaultCostInput = CreateAndAttachDkpCostFrame("Other:", "default", itemCostSectionRight, TdkpOptionsFrame.offhandCostInput);

end

function View:ToggleOptionsFrame()
    TdkpOptionsFrame:SetShown(not TdkpOptionsFrame:IsShown());
end

function View:HideOptionsFrame()
    TdkpOptionsFrame:SetShown(false);
end

