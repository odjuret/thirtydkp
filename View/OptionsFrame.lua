local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local OptionsFrame = nil;

local OPTIONS_FRAME_TITLE = "Options"


local function CreateDkpCostInputFrame(text, itemName, parent)
    local options = DAL:GetOptions();
    local frame = View:CreateInputFrame(parent, text, options.itemCosts[itemName], function(input)
        options.itemCosts[itemName] = input:GetNumber();
    end);

    return frame;
end

local function CreateAndAttachDkpCostFrame(text, itemName, parent, attachTarget)
    local frame = CreateDkpCostInputFrame(text, itemName, parent);
    frame:SetPoint(Const.TOP_LEFT_POINT, attachTarget, Const.BOTTOM_LEFT_POINT, 0, 0);
    return frame;
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

	local dkpGainPerKill = View:CreateInputFrame(miscSectionLeft, "DKP Per Kill:", options.dkpGainPerKill, function(input)
        options.dkpGainPerKill = input:GetNumber();
    end);
    dkpGainPerKill:SetPoint(Const.TOP_LEFT_POINT, miscSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

    local onTimeBonus = View:CreateInputFrame(miscSectionLeft, "On Time Bonus:", options.onTimeBonus, function(input)
        options.onTimeBonus = input:GetNumber();
    end);
	onTimeBonus:SetPoint(Const.TOP_LEFT_POINT, dkpGainPerKill, Const.BOTTOM_LEFT_POINT, 0, 0);

	local raidCompletionBonus = View:CreateInputFrame(miscSectionRight, "Raid Completion Bonus:", options.raidCompletionBonus, function(input)
        options.raidCompletionBonus = input:GetNumber();
    end);
	raidCompletionBonus:SetPoint(Const.TOP_LEFT_POINT, miscSectionRight, Const.TOP_LEFT_POINT, 0, 0);

	local decay = View:CreateInputFrame(miscSectionRight, "Decay Percent:", options.decay, function(input)
        options.decay = input:GetNumber();
    end);
	decay:SetPoint(Const.TOP_LEFT_POINT, raidCompletionBonus, Const.BOTTOM_LEFT_POINT, 0, 0);


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
    local headCostInput = CreateDkpCostInputFrame("Head:", "head", itemCostSectionLeft);
    headCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

    local neckCostInput = CreateAndAttachDkpCostFrame("Neck:", "neck", itemCostSectionLeft, headCostInput);
    local shouldersCostInput = CreateAndAttachDkpCostFrame("Shoulders:", "shoulders", itemCostSectionLeft, neckCostInput);
    local chestCostInput = CreateAndAttachDkpCostFrame("Chest:", "chest", itemCostSectionLeft, shouldersCostInput);
    local bracersCostInput = CreateAndAttachDkpCostFrame("Bracers:", "bracers", itemCostSectionLeft, chestCostInput);
    local glovesCostInput = CreateAndAttachDkpCostFrame("Gloves:", "gloves", itemCostSectionLeft, bracersCostInput);
    local beltCostInput = CreateAndAttachDkpCostFrame("Belt:", "belt", itemCostSectionLeft, glovesCostInput);

    -- Right section
    local legsCostInput = CreateDkpCostInputFrame("Legs:", "legs", itemCostSectionRight, itemCostSectionRight);
    legsCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionRight, Const.TOP_LEFT_POINT, 0, 0);
    local bootsCostInput = CreateAndAttachDkpCostFrame("Boots:", "boots", itemCostSectionRight, legsCostInput);
    local ringCostInput = CreateAndAttachDkpCostFrame("Ring:", "ring", itemCostSectionRight, bootsCostInput);
    local trinketCostInput = CreateAndAttachDkpCostFrame("Trinket:", "trinket", itemCostSectionRight, ringCostInput);
    local oneHandedWeaponCostInput = CreateAndAttachDkpCostFrame("One-handed:", "oneHandedWeapon", itemCostSectionRight, trinketCostInput);
    local twoHandedWeaponCostInput = CreateAndAttachDkpCostFrame("Two-handed:", "twoHandedWeapon", itemCostSectionRight, oneHandedWeaponCostInput);
    local rangedWeaponCostInput = CreateAndAttachDkpCostFrame("Ranged:", "rangedWeapon", itemCostSectionRight, twoHandedWeaponCostInput);


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
