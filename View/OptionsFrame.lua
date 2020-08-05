local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local OptionsFrame = nil;

local OPTIONS_FRAME_TITLE = "Options"

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
	local options = DAL:GetRaidOptions(SelectedRaid);
	OptionsFrame.dkpGainPerKill.input:SetNumber(options.dkpGainPerKill);
	OptionsFrame.headCostInput.input:SetNumber(options.itemCosts.head);
	OptionsFrame.neckCostInput.input:SetNumber(options.itemCosts.neck);
	OptionsFrame.shouldersCostInput.input:SetNumber(options.itemCosts.shoulders);
	OptionsFrame.chestCostInput.input:SetNumber(options.itemCosts.chest);
	OptionsFrame.bracersCostInput.input:SetNumber(options.itemCosts.bracers);
	OptionsFrame.glovesCostInput.input:SetNumber(options.itemCosts.gloves);
	OptionsFrame.beltCostInput.input:SetNumber(options.itemCosts.belt);
	OptionsFrame.legsCostInput.input:SetNumber(options.itemCosts.legs);
	OptionsFrame.bootsCostInput.input:SetNumber(options.itemCosts.boots);
	OptionsFrame.ringCostInput.input:SetNumber(options.itemCosts.ring);
	OptionsFrame.trinketCostInput.input:SetNumber(options.itemCosts.trinket);
	OptionsFrame.oneHandedWeaponCostInput.input:SetNumber(options.itemCosts.oneHandedWeapon);
	OptionsFrame.twoHandedWeaponCostInput.input:SetNumber(options.itemCosts.twoHandedWeapon);
	OptionsFrame.rangedWeaponCostInput.input:SetNumber(options.itemCosts.rangedWeapon);
end

local function RaidDropdownOnClick(self, arg1, arg2, checked)
	SelectedRaid = arg1;
	UIDropDownMenu_SetText(OptionsFrame.raidDropdown, Const.RAID_DISPLAY_NAME[arg1]);
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
	OptionsFrame = CreateFrame("Frame", "ThirtyDKP_OptionsFrame", parentFrame, "TooltipBorderedFrameTemplate"); 
	OptionsFrame:SetShown(false);
	OptionsFrame:SetSize(370, 450);
	OptionsFrame:SetFrameStrata("HIGH");
	OptionsFrame:SetPoint(Const.TOP_LEFT_POINT, parentFrame, Const.TOP_RIGHT_POINT, 0, 0); -- point, relative frame, relative point on relative frame
    OptionsFrame:EnableMouse(true);

    -- title
    local title = OptionsFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
    title:SetFontObject("GameFontNormal");
    title:SetPoint(Const.TOP_LEFT_POINT, OptionsFrame, Const.TOP_LEFT_POINT, 15, -10);
    title:SetText(OPTIONS_FRAME_TITLE);

	local options = DAL:GetOptions();
    local raidOptions = DAL:GetRaidOptions(SelectedRaid);

	local globalOptionsHeader = OptionsFrame:CreateFontString(nil, OVERLAY_LAYER);
	globalOptionsHeader:SetFontObject("GameFontWhite");
	globalOptionsHeader:SetPoint(Const.TOP_LEFT_POINT, OptionsFrame, Const.TOP_LEFT_POINT, 10, -35);
	globalOptionsHeader:SetText("Global Options");


    -- global settings, two sections
    local globalSectionLeft = CreateFrame("Frame", nil, OptionsFrame, nil);
    globalSectionLeft:SetSize(180, 70);
    globalSectionLeft:SetPoint(Const.TOP_LEFT_POINT, globalOptionsHeader, Const.BOTTOM_LEFT_POINT, 10, -10);

    local globalSectionRight = CreateFrame("Frame", nil, OptionsFrame, nil);
    globalSectionRight:SetSize(135, 70);
    globalSectionRight:SetPoint(Const.TOP_LEFT_POINT, globalSectionLeft, Const.TOP_RIGHT_POINT, 20, 0);

    OptionsFrame.onTimeBonus = View:CreateNumericInputFrame(globalSectionLeft, "On Time Bonus:", options.onTimeBonus, function(input)
        options.onTimeBonus = input:GetNumber();
    end);
	OptionsFrame.onTimeBonus:SetPoint(Const.TOP_LEFT_POINT, globalSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

	OptionsFrame.raidCompletionBonus = View:CreateNumericInputFrame(globalSectionLeft, "Raid Completion Bonus:", options.raidCompletionBonus, function(input)
        options.raidCompletionBonus = input:GetNumber();
    end);
	OptionsFrame.raidCompletionBonus:SetPoint(Const.TOP_LEFT_POINT, OptionsFrame.onTimeBonus, Const.BOTTOM_LEFT_POINT, 0, 0);

	OptionsFrame.decay = View:CreateNumericInputFrame(globalSectionRight, "Decay Percent:", options.decay, function(input)
        options.decay = input:GetNumber();
    end);
	OptionsFrame.decay:SetPoint(Const.TOP_LEFT_POINT);


	local raidOptionsHeader = OptionsFrame:CreateFontString(nil, OVERLAY_LAYER);
	raidOptionsHeader:SetFontObject("GameFontWhite");
	raidOptionsHeader:SetPoint(Const.TOP_LEFT_POINT, globalSectionLeft, Const.BOTTOM_LEFT_POINT, -10, 0);
	raidOptionsHeader:SetText("Raid Specific Options for: ");

	OptionsFrame.raidDropdown = CreateFrame("Frame", "ThirtyDKP_RaidOptionsDropdown", OptionsFrame, "UIDropDownMenuTemplate");
	OptionsFrame.raidDropdown:SetPoint(Const.LEFT_POINT, raidOptionsHeader, Const.RIGHT_POINT, 0, -4);
	UIDropDownMenu_SetWidth(OptionsFrame.raidDropdown, 110);
	UIDropDownMenu_Initialize(OptionsFrame.raidDropdown, InitializeRaidDropdown);
	UIDropDownMenu_SetText(OptionsFrame.raidDropdown, Const.RAID_DISPLAY_NAME[SelectedRaid]);


	local dkpGainSection = CreateFrame("Frame", nil, OptionsFrame, nil);
	dkpGainSection:SetSize(115, 30);
	dkpGainSection:SetPoint(Const.TOP_LEFT_POINT, raidOptionsHeader, Const.BOTTOM_LEFT_POINT, 10, -10);
	OptionsFrame.dkpGainPerKill = View:CreateNumericInputFrame(dkpGainSection, "DKP Per Kill:", raidOptions.dkpGainPerKill, function(input)
		DAL:GetRaidOptions(SelectedRaid).dkpGainPerKill = input:GetNumber();
    end);
    OptionsFrame.dkpGainPerKill:SetAllPoints();

	local itemCostHeader = OptionsFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	itemCostHeader:SetFontObject("GameFontNormal");
	itemCostHeader:SetPoint(Const.TOP_LEFT_POINT, dkpGainSection, Const.BOTTOM_LEFT_POINT, 0, -10);
	itemCostHeader:SetText("Item Costs");

    -- Item cost setting, two sections
    local itemCostSectionLeft = CreateFrame("Frame", nil, OptionsFrame, nil);
    itemCostSectionLeft:SetSize(105, 150);
    itemCostSectionLeft:SetPoint(Const.TOP_LEFT_POINT, itemCostHeader, Const.BOTTOM_LEFT_POINT, 10, -10);

    local itemCostSectionRight = CreateFrame("Frame", nil, OptionsFrame, nil);
    itemCostSectionRight:SetSize(115, 150);
    itemCostSectionRight:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionLeft, Const.TOP_RIGHT_POINT, 20, 0);

    -- Left section
    OptionsFrame.headCostInput = CreateDkpCostInputFrame("Head:", "head", itemCostSectionLeft);
    OptionsFrame.headCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

    OptionsFrame.neckCostInput = CreateAndAttachDkpCostFrame("Neck:", "neck", itemCostSectionLeft, OptionsFrame.headCostInput);
    OptionsFrame.shouldersCostInput = CreateAndAttachDkpCostFrame("Shoulders:", "shoulders", itemCostSectionLeft, OptionsFrame.neckCostInput);
    OptionsFrame.chestCostInput = CreateAndAttachDkpCostFrame("Chest:", "chest", itemCostSectionLeft, OptionsFrame.shouldersCostInput);
    OptionsFrame.bracersCostInput = CreateAndAttachDkpCostFrame("Bracers:", "bracers", itemCostSectionLeft, OptionsFrame.chestCostInput);
    OptionsFrame.glovesCostInput = CreateAndAttachDkpCostFrame("Gloves:", "gloves", itemCostSectionLeft, OptionsFrame.bracersCostInput);
    OptionsFrame.beltCostInput = CreateAndAttachDkpCostFrame("Belt:", "belt", itemCostSectionLeft, OptionsFrame.glovesCostInput);
    OptionsFrame.legsCostInput = CreateAndAttachDkpCostFrame("Legs:", "legs", itemCostSectionLeft, OptionsFrame.beltCostInput);

    -- Right section
    OptionsFrame.bootsCostInput = CreateDkpCostInputFrame("Boots:", "boots", itemCostSectionRight);
    OptionsFrame.bootsCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionRight, Const.TOP_LEFT_POINT, 0, 0);
    OptionsFrame.ringCostInput = CreateAndAttachDkpCostFrame("Ring:", "ring", itemCostSectionRight, OptionsFrame.bootsCostInput);
    OptionsFrame.trinketCostInput = CreateAndAttachDkpCostFrame("Trinket:", "trinket", itemCostSectionRight, OptionsFrame.ringCostInput);
    OptionsFrame.oneHandedWeaponCostInput = CreateAndAttachDkpCostFrame("One-handed:", "oneHandedWeapon", itemCostSectionRight, OptionsFrame.trinketCostInput);
    OptionsFrame.twoHandedWeaponCostInput = CreateAndAttachDkpCostFrame("Two-handed:", "twoHandedWeapon", itemCostSectionRight, OptionsFrame.oneHandedWeaponCostInput);
    OptionsFrame.rangedWeaponCostInput = CreateAndAttachDkpCostFrame("Ranged:", "rangedWeapon", itemCostSectionRight, OptionsFrame.twoHandedWeaponCostInput);
    OptionsFrame.offhandCostInput = CreateAndAttachDkpCostFrame("Offhand:", "offhand", itemCostSectionRight, OptionsFrame.rangedWeaponCostInput);


    -- Buttons
    OptionsFrame.closeBtn = CreateFrame("Button", nil, OptionsFrame, "UIPanelCloseButton")
	OptionsFrame.closeBtn:SetPoint(Const.TOP_RIGHT_POINT, OptionsFrame, Const.TOP_RIGHT_POINT)

end

function View:ToggleOptionsFrame()
    OptionsFrame:SetShown(not OptionsFrame:IsShown());
end

function View:HideOptionsFrame()
    OptionsFrame:SetShown(false);
end

