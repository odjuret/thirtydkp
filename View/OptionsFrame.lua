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
                View:UpdateDKPTable()
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
                    View:UpdateDKPTable()
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

local function AttachBroadcastDKPTableScript(frame)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText("Broadcast DKP table", 0.25, 0.75, 0.90, 1, true);
        GameTooltip:AddLine("Attempts to broadcast out the latest DKP table to other online members", 1.0, 1.0, 1.0, true);
        GameTooltip:Show();
    end);

    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end);

    frame:SetScript("OnClick", function ()
        StaticPopupDialogs["BROADCAST_DKPTABLE"] = {
            text = "Are you sure you want to broadcast your DKP table?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                Core:BroadcastDKPTable()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("BROADCAST_DKPTABLE")
    end);
end


local function CreateInputFrame(text, parent)
    local wrapper = CreateFrame("Frame", nil, parent, nil);
    wrapper:SetSize(150, 30);

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
    wrapper.input:SetNumber(0);
    wrapper.input:SetJustifyH("CENTER");
    wrapper.input:SetPoint(Const.TOP_RIGHT_POINT, wrapper, Const.TOP_RIGHT_POINT, 0, 0);
    wrapper.input:SetScript("OnEnterPressed", wrapper.input.ClearFocus);

    local tex = wrapper.input:CreateTexture(nil, "BACKGROUND");
    tex:SetAllPoints();
    tex:SetColorTexture(0.2, 0.2, 0.2);

    return wrapper;
end

local function CreateAndAttachInputFrame(text, parent, attachTarget)
    local frame = CreateInputFrame(text, parent);
    frame:SetPoint(Const.TOP_LEFT_POINT, attachTarget, Const.BOTTOMLEFT_POINT, 0, 0);
    return frame;
end

function View:CreateOptionsFrame(parentFrame)
	OptionsFrame = CreateFrame('Frame', 'ThirtyDKP_OptionsFrame', UIParent, "UIPanelDialogTemplate"); -- Todo: make mainframe owner??
	OptionsFrame:SetShown(false);
	OptionsFrame:SetSize(500, 500);
	OptionsFrame:SetFrameStrata("HIGH");
	--OptionsFrame:SetClampedToScreen(true);
	OptionsFrame:SetPoint(Const.TOP_LEFT_POINT, parentFrame, Const.TOP_RIGHT_POINT, 0, 0); -- point, relative frame, relative point on relative frame
	OptionsFrame:EnableMouse(true);

    -- title
    local title = OptionsFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
    title:SetFontObject("GameFontNormal");
    title:ClearAllPoints();
    title:SetPoint(Const.TOP_LEFT_POINT, OptionsFrame, Const.TOP_LEFT_POINT, 15, -10);
    title:SetText(OPTIONS_FRAME_TITLE);


    -- Misc
    local dkpGainPerKill = CreateInputFrame("DKP Per Kill:", OptionsFrame);
    dkpGainPerKill:SetPoint(Const.TOP_LEFT_POINT, OptionsFrame, Const.TOP_LEFT_POINT, 30, -50);


    -- Item cost setting, two sections
    local itemCostSectionLeft = CreateFrame("Frame", nil, OptionsFrame, nil);
    itemCostSectionLeft:SetSize(180, 150);
    itemCostSectionLeft:SetPoint(Const.TOP_LEFT_POINT, dkpGainPerKill, Const.BOTTOMLEFT_POINT, 0, -25);

    local itemCostSectionRight = CreateFrame("Frame", nil, OptionsFrame, nil);
    itemCostSectionRight:SetSize(180, 150);
    itemCostSectionRight:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionLeft, Const.TOP_RIGHT_POINT, 0, 0);

    -- Left section
    local headCostInput = CreateInputFrame("Head Cost:", itemCostSectionLeft, itemCostSectionLeft);
    headCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionLeft, Const.TOP_LEFT_POINT, 0, 0);

    local neckCostInput = CreateAndAttachInputFrame("Neck Cost:", itemCostSectionLeft, headCostInput);
    local shouldersCostInput = CreateAndAttachInputFrame("Shoulders Cost:", itemCostSectionLeft, neckCostInput);
    local chestCostInput = CreateAndAttachInputFrame("Chest Cost:", itemCostSectionLeft, shouldersCostInput);
    local bracersCostInput = CreateAndAttachInputFrame("Bracers Cost:", itemCostSectionLeft, chestCostInput);
    local glovesCostInput = CreateAndAttachInputFrame("Gloves Cost:", itemCostSectionLeft, bracersCostInput);
    local oneHandedWeaponCostInput = CreateAndAttachInputFrame("1h Weapon Cost:", itemCostSectionLeft, glovesCostInput);
    local twoHandedWeaponCostInput = CreateAndAttachInputFrame("2h Weapon Cost:", itemCostSectionLeft, oneHandedWeaponCostInput);
    local rangedWeaponCostInput = CreateAndAttachInputFrame("Ranged Cost:", itemCostSectionLeft, twoHandedWeaponCostInput);

    -- Right section
    local beltCostInput = CreateInputFrame("Belt Cost:", itemCostSectionRight, itemCostSectionRight);
    beltCostInput:SetPoint(Const.TOP_LEFT_POINT, itemCostSectionRight, Const.TOP_LEFT_POINT, 0, 0);

    local legsCostInput = CreateAndAttachInputFrame("Legs Cost:", itemCostSectionRight, beltCostInput);
    local bootsCostInput = CreateAndAttachInputFrame("Boots Cost:", itemCostSectionRight, legsCostInput);
    local ringCostInput = CreateAndAttachInputFrame("Ring Cost:", itemCostSectionRight, bootsCostInput);
    local trinketCostInput = CreateAndAttachInputFrame("Trinket Cost:", itemCostSectionRight, ringCostInput);


    -- Buttons 
    --  add raid to dkp table button
    OptionsFrame.addRaidToTableBtn = CreateFrame("Button", nil, OptionsFrame, "GameMenuButtonTemplate");
    OptionsFrame.addRaidToTableBtn:SetPoint(Const.BOTTOMLEFT_POINT, OptionsFrame, Const.BOTTOMLEFT_POINT, 10, 10);
    OptionsFrame.addRaidToTableBtn:SetSize(80, 30);
    OptionsFrame.addRaidToTableBtn:SetText("Add Raid");
    OptionsFrame.addRaidToTableBtn:SetNormalFontObject("GameFontNormal");
    OptionsFrame.addRaidToTableBtn:SetHighlightFontObject("GameFontHighlight");
    OptionsFrame.addRaidToTableBtn:RegisterForClicks("AnyUp");
    
    AttachAddRaidToTableScripts(OptionsFrame.addRaidToTableBtn)

	--  add guild to dkp table button
	OptionsFrame.addGuildToTableBtn = CreateFrame("Button", nil, OptionsFrame, "GameMenuButtonTemplate");
	OptionsFrame.addGuildToTableBtn:SetPoint(Const.BOTTOMLEFT_POINT, OptionsFrame, Const.BOTTOMLEFT_POINT, 90, 10);
	OptionsFrame.addGuildToTableBtn:SetSize(80, 30);
	OptionsFrame.addGuildToTableBtn:SetText("Add Guild");
	OptionsFrame.addGuildToTableBtn:SetNormalFontObject("GameFontNormal");
	OptionsFrame.addGuildToTableBtn:SetHighlightFontObject("GameFontHighlight");
	OptionsFrame.addGuildToTableBtn:RegisterForClicks("AnyUp");

    AttachAddGuildToTableScript(OptionsFrame.addGuildToTableBtn);
    
    --  broadcast dkp table to online members button
    OptionsFrame.broadcastBtn = CreateFrame("Button", nil, OptionsFrame, "GameMenuButtonTemplate");
	OptionsFrame.broadcastBtn:SetPoint(Const.BOTTOMLEFT_POINT, OptionsFrame, Const.BOTTOMLEFT_POINT, 170, 10);
	OptionsFrame.broadcastBtn:SetSize(80, 30);
	OptionsFrame.broadcastBtn:SetText("Broadcast");
	OptionsFrame.broadcastBtn:SetNormalFontObject("GameFontNormal");
	OptionsFrame.broadcastBtn:SetHighlightFontObject("GameFontHighlight");
    OptionsFrame.broadcastBtn:RegisterForClicks("AnyUp");
    
    AttachBroadcastDKPTableScript(OptionsFrame.broadcastBtn);
end

function View:ToggleOptionsFrame()
    OptionsFrame:SetShown(not OptionsFrame:IsShown());
end

function View:HideOptionsFrame()
    OptionsFrame:SetShown(false);
end