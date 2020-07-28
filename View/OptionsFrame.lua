local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local OptionsFrame = nil;

local OPTIONS_FRAME_TITLE = "Options"


local function CreateDkpCostInputFrame(text, itemName, parent)
    local options = DAL:GetOptions();
    local frame = View:CreateNumericInputFrame(parent, text, options.itemCosts[itemName], function(input)
        options.itemCosts[itemName] = input:GetNumber();
    end);

    return frame;
end

local function CreateAndAttachDkpCostFrame(text, itemName, parent, attachTarget)
    local frame = CreateDkpCostInputFrame(text, itemName, parent);
    frame:SetPoint(Const.TOP_LEFT_POINT, attachTarget, Const.BOTTOM_LEFT_POINT, 0, 0);
    return frame;
end

function View:UpdateOptionsFrame()
	local options = DAL:GetOptions();
	OptionsFrame.dkpGainPerKill.input:SetNumber(options.dkpGainPerKill);
	OptionsFrame.onTimeBonus.input:SetNumber(options.onTimeBonus);
	OptionsFrame.raidCompletionBonus.input:SetNumber(options.raidCompletionBonus);
	OptionsFrame.decay.input:SetNumber(options.decay);

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


function View:CreateOptionsFrame(parentFrame, savedOptions)
	OptionsFrame = CreateFrame("Frame", "ThirtyDKP_OptionsFrame", parentFrame, "TooltipBorderedFrameTemplate"); 
	OptionsFrame:SetShown(false);
	OptionsFrame:SetSize(370, 375);
	OptionsFrame:SetFrameStrata("HIGH");
	OptionsFrame:SetPoint(Const.TOP_LEFT_POINT, parentFrame, Const.TOP_RIGHT_POINT, 0, 0); -- point, relative frame, relative point on relative frame
    OptionsFrame:EnableMouse(true);

    -- title
    local title = OptionsFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
    title:SetFontObject("GameFontNormal");
    title:SetPoint(Const.TOP_LEFT_POINT, OptionsFrame, Const.TOP_LEFT_POINT, 15, -10);
    title:SetText(OPTIONS_FRAME_TITLE);

    local options = DAL:GetOptions();

	local miscSectionHeader = OptionsFrame:CreateFontString(nil, OVERLAY_LAYER);
	miscSectionHeader:SetFontObject("GameFontWhite");
	miscSectionHeader:SetPoint(Const.TOP_LEFT_POINT, OptionsFrame, Const.TOP_LEFT_POINT, 10, -35);
	miscSectionHeader:SetText("Miscellaneous");

    -- Misc settings, two sections
    local miscSectionLeft = CreateFrame("Frame", nil, OptionsFrame, nil);
    miscSectionLeft:SetSize(135, 70);
    miscSectionLeft:SetPoint(Const.TOP_LEFT_POINT, miscSectionHeader, Const.BOTTOM_LEFT_POINT, 10, -10);

    local miscSectionRight = CreateFrame("Frame", nil, OptionsFrame, nil);
    miscSectionRight:SetSize(180, 70);
    miscSectionRight:SetPoint(Const.TOP_LEFT_POINT, miscSectionLeft, Const.TOP_RIGHT_POINT, 20, 0);

	OptionsFrame.dkpGainPerKill = View:CreateNumericInputFrame(miscSectionLeft, "DKP Per Kill:", options.dkpGainPerKill, function(input)
        options.dkpGainPerKill = input:GetNumber();
    end);
    OptionsFrame.dkpGainPerKill:SetPoint(Const.TOP_LEFT_POINT, miscSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

    OptionsFrame.onTimeBonus = View:CreateNumericInputFrame(miscSectionLeft, "On Time Bonus:", options.onTimeBonus, function(input)
        options.onTimeBonus = input:GetNumber();
    end);
	OptionsFrame.onTimeBonus:SetPoint(Const.TOP_LEFT_POINT, dkpGainPerKill, Const.BOTTOM_LEFT_POINT, 0, 0);

	OptionsFrame.raidCompletionBonus = View:CreateNumericInputFrame(miscSectionRight, "Raid Completion Bonus:", options.raidCompletionBonus, function(input)
        options.raidCompletionBonus = input:GetNumber();
    end);
	OptionsFrame.raidCompletionBonus:SetPoint(Const.TOP_LEFT_POINT, miscSectionRight, Const.TOP_LEFT_POINT, 0, 0);

	OptionsFrame.decay = View:CreateNumericInputFrame(miscSectionRight, "Decay Percent:", options.decay, function(input)
        options.decay = input:GetNumber();
    end);
	OptionsFrame.decay:SetPoint(Const.TOP_LEFT_POINT, raidCompletionBonus, Const.BOTTOM_LEFT_POINT, 0, 0);


	local itemCostHeader = OptionsFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	itemCostHeader:SetFontObject("GameFontWhite");
	itemCostHeader:SetPoint(Const.TOP_LEFT_POINT, miscSectionLeft, Const.BOTTOM_LEFT_POINT, -10, -10);
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

    -- Right section
    OptionsFrame.legsCostInput = CreateDkpCostInputFrame("Legs:", "legs", itemCostSectionRight, itemCostSectionRight);
    OptionsFrame.legsCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionRight, Const.TOP_LEFT_POINT, 0, 0);
    OptionsFrame.bootsCostInput = CreateAndAttachDkpCostFrame("Boots:", "boots", itemCostSectionRight, OptionsFrame.legsCostInput);
    OptionsFrame.ringCostInput = CreateAndAttachDkpCostFrame("Ring:", "ring", itemCostSectionRight, OptionsFrame.bootsCostInput);
    OptionsFrame.trinketCostInput = CreateAndAttachDkpCostFrame("Trinket:", "trinket", itemCostSectionRight, OptionsFrame.ringCostInput);
    OptionsFrame.oneHandedWeaponCostInput = CreateAndAttachDkpCostFrame("One-handed:", "oneHandedWeapon", itemCostSectionRight, OptionsFrame.trinketCostInput);
    OptionsFrame.twoHandedWeaponCostInput = CreateAndAttachDkpCostFrame("Two-handed:", "twoHandedWeapon", itemCostSectionRight, OptionsFrame.oneHandedWeaponCostInput);
    OptionsFrame.rangedWeaponCostInput = CreateAndAttachDkpCostFrame("Ranged:", "rangedWeapon", itemCostSectionRight, OptionsFrame.twoHandedWeaponCostInput);


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
