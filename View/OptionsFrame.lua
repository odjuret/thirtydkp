local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local OptionsFrame = nil;

local OPTIONS_FRAME_TITLE = "Options"

local function CreateInputFrame(parent, text, value, valueChangedCallback)
    local wrapper = CreateFrame("Frame", nil, parent, nil);
    wrapper:SetSize(parent:GetWidth(), 30);

    wrapper.label = wrapper:CreateFontString(nil, Const.OVERLAY_LAYER);
    wrapper.label:SetFontObject("GameFontNormal");
    wrapper.label:ClearAllPoints();
    wrapper.label:SetText(text);
    wrapper.label:SetPoint(Const.TOP_LEFT_POINT, wrapper, Const.TOP_LEFT_POINT, 0, -5)

    wrapper.input = CreateFrame("EditBox", nil, wrapper, nil);
    wrapper.input:SetFontObject("GameFontNormal");
    wrapper.input:SetSize(30, 20);
    wrapper.input:SetAutoFocus(false);
    wrapper.input:SetNumeric(true);
    wrapper.input:SetNumber(value);
    wrapper.input:SetJustifyH("CENTER");
    wrapper.input:SetPoint(Const.TOP_RIGHT_POINT, wrapper, Const.TOP_RIGHT_POINT, 0, 0);
    wrapper.input:SetScript("OnEnterPressed", function(self)
        valueChangedCallback(self);
        self:ClearFocus();
    end);

    local tex = wrapper.input:CreateTexture(nil, "BACKGROUND");
    tex:SetAllPoints();
    tex:SetColorTexture(0.2, 0.2, 0.2);

    return wrapper;
end

local function CreateDkpCostInputFrame(text, itemName, parent)
    local options = DAL:GetOptions();
    local frame = CreateInputFrame(parent, text, options.itemCosts[itemName], function(input)
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
	OptionsFrame = CreateFrame("Frame", "ThirtyDKP_OptionsFrame", UIParent, "TooltipBorderedFrameTemplate"); -- Todo: make mainframe owner??
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

	local dkpGainPerKill = CreateInputFrame(miscSectionLeft, "DKP Per Kill:", options.dkpGainPerKill, function(input)
        options.dkpGainPerKill = input:GetNumber();
    end);
    dkpGainPerKill:SetPoint(Const.TOP_LEFT_POINT, miscSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

    local onTimeBonus = CreateInputFrame(miscSectionLeft, "On Time Bonus:", options.onTimeBonus, function(input)
        options.onTimeBonus = input:GetNumber();
    end);
	onTimeBonus:SetPoint(Const.TOP_LEFT_POINT, dkpGainPerKill, Const.BOTTOM_LEFT_POINT, 0, 0);

	local raidCompletionBonus = CreateInputFrame(miscSectionRight, "Raid Completion Bonus:", options.raidCompletionBonus, function(input)
        options.raidCompletionBonus = input:GetNumber();
    end);
	raidCompletionBonus:SetPoint(Const.TOP_LEFT_POINT, miscSectionRight, Const.TOP_LEFT_POINT, 0, 0);

	local decay = CreateInputFrame(miscSectionRight, "Decay Percent:", options.decay, function(input)
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
    local oneHandedWeaponCostInput = CreateAndAttachDkpCostFrame("1h Weapon:", "oneHandedWeapon", itemCostSectionRight, trinketCostInput);
    local twoHandedWeaponCostInput = CreateAndAttachDkpCostFrame("2h Weapon:", "twoHandedWeapon", itemCostSectionRight, oneHandedWeaponCostInput);
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
