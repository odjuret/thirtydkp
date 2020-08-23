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
    local frame = View:CreateNumericInputFrame(parent, text, options.itemCosts[itemName], function(input)
		DAL:GetRaidOptions(SelectedRaid).itemCosts[itemName] = input:GetNumber();
    end);

    return frame;
end

local function CreateAndAttachDkpCostFrame(text, itemName, parent, attachTarget)
    local frame = CreateDkpCostInputFrame(text, itemName, parent);
    frame:SetPoint(Const.TOP_LEFT_POINT, attachTarget, Const.BOTTOM_LEFT_POINT, 0, 0);
    return frame;
end

function View:UpdateOptionsFrame()
	SelectedRaid = DAL:GetLastSelectedRaid();
	local options = DAL:GetRaidOptions(SelectedRaid);
	TdkpOptionsFrame.dkpGainPerKill.input:SetNumber(options.dkpGainPerKill);
	TdkpOptionsFrame.headCostInput.input:SetNumber(options.itemCosts.head);
	TdkpOptionsFrame.neckCostInput.input:SetNumber(options.itemCosts.neck);
	TdkpOptionsFrame.shouldersCostInput.input:SetNumber(options.itemCosts.shoulders);
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
end

local function RaidDropdownOnClick(self, arg1, arg2, checked)
	SelectedRaid = arg1;
	DAL:SetLastSelectedRaid(arg1)
	UIDropDownMenu_SetText(TdkpOptionsFrame.raidDropdown, Const.RAID_DISPLAY_NAME[arg1]);
	View:UpdateOptionsFrame();
end

local function InitializeRaidDropdown(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo();
	info.func = RaidDropdownOnClick;

	info.text = "Naxxramas";
	info.arg1 = Const.RAID_NAXX;
	info.arg2 = info.text;
	info.checked = SelectedRaid == Const.RAID_NAXX;
	UIDropDownMenu_AddButton(info);

	info.text = "Ahn'Qiraj";
	info.arg1 = Const.RAID_AQ40;
	info.arg2 = info.text;
	info.checked = SelectedRaid == Const.RAID_AQ40;
	UIDropDownMenu_AddButton(info);

	info.text = "Blackwing Lair";
	info.arg1 = Const.RAID_BWL;
	info.arg2 = info.text;
	info.checked = SelectedRaid == Const.RAID_BWL;
	UIDropDownMenu_AddButton(info);

	info.text = "Molten Core";
	info.arg1 = Const.RAID_MC;
	info.arg2 = info.text;
	info.checked = SelectedRaid == Const.RAID_MC;
	UIDropDownMenu_AddButton(info);

	info.text = "Onyxia";
	info.arg1 = Const.RAID_ONYXIA;
	info.arg2 = info.text;
	info.checked = selectedRaid == Const.RAID_ONYXIA;
	UIDropDownMenu_AddButton(info);
end

function View:CreateOptionsFrame(parentFrame)
	TdkpOptionsFrame = View:CreateContainerFrame("ThirtyDKP_OptionsFrame", parentFrame, TDKP_OPTIONS_FRAME_TITLE, 370, 450);

	local options = DAL:GetOptions();
	SelectedRaid = options.lastSelectedRaid
    local raidOptions = DAL:GetRaidOptions(SelectedRaid);

	local globalOptionsHeader = TdkpOptionsFrame:CreateFontString(nil, OVERLAY_LAYER);
	globalOptionsHeader:SetFontObject("GameFontWhite");
	globalOptionsHeader:SetPoint(Const.TOP_LEFT_POINT, TdkpOptionsFrame, Const.TOP_LEFT_POINT, 10, -35);
	globalOptionsHeader:SetText("Global Options");


    -- global settings, two sections
    local globalSectionLeft = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
    globalSectionLeft:SetSize(180, 70);
    globalSectionLeft:SetPoint(Const.TOP_LEFT_POINT, globalOptionsHeader, Const.BOTTOM_LEFT_POINT, 10, -10);

    local globalSectionRight = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
    globalSectionRight:SetSize(135, 70);
    globalSectionRight:SetPoint(Const.TOP_LEFT_POINT, globalSectionLeft, Const.TOP_RIGHT_POINT, 20, 0);

    TdkpOptionsFrame.onTimeBonus = View:CreateNumericInputFrame(globalSectionLeft, "On Time Bonus:", options.onTimeBonus, function(input)
        options.onTimeBonus = input:GetNumber();
    end);
	TdkpOptionsFrame.onTimeBonus:SetPoint(Const.TOP_LEFT_POINT, globalSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

	TdkpOptionsFrame.raidCompletionBonus = View:CreateNumericInputFrame(globalSectionLeft, "Raid Completion Bonus:", options.raidCompletionBonus, function(input)
        options.raidCompletionBonus = input:GetNumber();
    end);
	TdkpOptionsFrame.raidCompletionBonus:SetPoint(Const.TOP_LEFT_POINT, TdkpOptionsFrame.onTimeBonus, Const.BOTTOM_LEFT_POINT, 0, 0);

	TdkpOptionsFrame.decay = View:CreateNumericInputFrame(globalSectionRight, "Decay Percent:", options.decay, function(input)
        options.decay = input:GetNumber();
    end);
	TdkpOptionsFrame.decay:SetPoint(Const.TOP_LEFT_POINT);


	local raidOptionsHeader = TdkpOptionsFrame:CreateFontString(nil, OVERLAY_LAYER);
	raidOptionsHeader:SetFontObject("GameFontWhite");
	raidOptionsHeader:SetPoint(Const.TOP_LEFT_POINT, globalSectionLeft, Const.BOTTOM_LEFT_POINT, -10, 0);
	raidOptionsHeader:SetText("Raid Specific Options for: ");

	TdkpOptionsFrame.raidDropdown = CreateFrame("Frame", "ThirtyDKP_RaidOptionsDropdown", TdkpOptionsFrame, "UIDropDownMenuTemplate");
	TdkpOptionsFrame.raidDropdown:SetPoint(Const.LEFT_POINT, raidOptionsHeader, Const.RIGHT_POINT, 0, -4);
	UIDropDownMenu_SetWidth(TdkpOptionsFrame.raidDropdown, 110);
	UIDropDownMenu_Initialize(TdkpOptionsFrame.raidDropdown, InitializeRaidDropdown);
	UIDropDownMenu_SetText(TdkpOptionsFrame.raidDropdown, Const.RAID_DISPLAY_NAME[SelectedRaid]);


	local dkpGainSection = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
	dkpGainSection:SetSize(115, 30);
	dkpGainSection:SetPoint(Const.TOP_LEFT_POINT, raidOptionsHeader, Const.BOTTOM_LEFT_POINT, 10, -10);
	TdkpOptionsFrame.dkpGainPerKill = View:CreateNumericInputFrame(dkpGainSection, "DKP Per Kill:", raidOptions.dkpGainPerKill, function(input)
		DAL:GetRaidOptions(SelectedRaid).dkpGainPerKill = input:GetNumber();
    end);
    TdkpOptionsFrame.dkpGainPerKill:SetAllPoints();

	local itemCostHeader = TdkpOptionsFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	itemCostHeader:SetFontObject("GameFontNormal");
	itemCostHeader:SetPoint(Const.TOP_LEFT_POINT, dkpGainSection, Const.BOTTOM_LEFT_POINT, 0, -10);
	itemCostHeader:SetText("Item Costs");

    -- Item cost setting, two sections
    local itemCostSectionLeft = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
    itemCostSectionLeft:SetSize(105, 150);
    itemCostSectionLeft:SetPoint(Const.TOP_LEFT_POINT, itemCostHeader, Const.BOTTOM_LEFT_POINT, 10, -10);

    local itemCostSectionRight = CreateFrame("Frame", nil, TdkpOptionsFrame, nil);
    itemCostSectionRight:SetSize(115, 150);
    itemCostSectionRight:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionLeft, Const.TOP_RIGHT_POINT, 20, 0);

    -- Left section
    TdkpOptionsFrame.headCostInput = CreateDkpCostInputFrame("Head:", "head", itemCostSectionLeft);
    TdkpOptionsFrame.headCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

    TdkpOptionsFrame.neckCostInput = CreateAndAttachDkpCostFrame("Neck:", "neck", itemCostSectionLeft, TdkpOptionsFrame.headCostInput);
    TdkpOptionsFrame.shouldersCostInput = CreateAndAttachDkpCostFrame("Shoulders:", "shoulders", itemCostSectionLeft, TdkpOptionsFrame.neckCostInput);
    TdkpOptionsFrame.chestCostInput = CreateAndAttachDkpCostFrame("Chest:", "chest", itemCostSectionLeft, TdkpOptionsFrame.shouldersCostInput);
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

end

function View:ToggleOptionsFrame()
    TdkpOptionsFrame:SetShown(not TdkpOptionsFrame:IsShown());
end

function View:HideOptionsFrame()
    TdkpOptionsFrame:SetShown(false);
end

