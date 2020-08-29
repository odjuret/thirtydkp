local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local AddGuildFrame = nil;

local ADDGUILD_FRAME_TITLE = "Add guild"

local selectedGuildRank = "";

local function RankDropdownOnClick(self, arg1, arg2, checked)
	selectedGuildRank = arg2;
	L_UIDropDownMenu_SetText(AddGuildFrame.rankDropdown, arg2);
	View:UpdateOptionsFrame();
end

local function InitializeRankDropdown()
    local ranks = DAL:GetGuildRankInfo()

    local rankDropdownInfo = L_UIDropDownMenu_CreateInfo();
    rankDropdownInfo.func = RankDropdownOnClick;
    
    for i=1, #ranks do
        rankDropdownInfo.text = ranks[i];
        rankDropdownInfo.arg1 = i;
        rankDropdownInfo.arg2 = rankDropdownInfo.text;
        rankDropdownInfo.checked = selectedGuildRank == ranks[i]
        L_UIDropDownMenu_AddButton(rankDropdownInfo);
    end
end

function View:CreateAddGuildFrame(parentFrame)
    AddGuildFrame = View:CreateContainerFrame("ThirtyDKP_AddGuildFrame", parentFrame, ADDGUILD_FRAME_TITLE, 300, 100);

    AddGuildFrame.rankDropdown = CreateFrame("Frame", "ThirtyDKP_RankDropdown", AddGuildFrame, "L_UIDropDownMenuTemplate");
    AddGuildFrame.rankDropdown:SetPoint(Const.LEFT_POINT, AddGuildFrame, Const.TOP_LEFT_POINT, 5, -60);
    
	L_UIDropDownMenu_SetWidth(AddGuildFrame.rankDropdown, 110);
	L_UIDropDownMenu_Initialize(AddGuildFrame.rankDropdown, InitializeRankDropdown);
    L_UIDropDownMenu_SetText(AddGuildFrame.rankDropdown, selectedGuildRank);
    
    local addGuildRankBtn = CreateFrame("Button", nil, AddGuildFrame, "GameMenuButtonTemplate");
	addGuildRankBtn:SetSize(80, Const.ButtonHeight);
    addGuildRankBtn:SetPoint(Const.LEFT_POINT, AddGuildFrame.rankDropdown, Const.RIGHT_POINT, 0, 0);

    addGuildRankBtn:SetText("Add rank");
    addGuildRankBtn:SetNormalFontObject("GameFontNormal");
    addGuildRankBtn:SetHighlightFontObject("GameFontHighlight");
    
    View:AttachHoverOverTooltipAndOnclick(addGuildRankBtn, "Add members from the selected rank to the DKP table", "Adds guild members of selected rank that aren't in the dkp table", function()
        -- If not in guild
        if not IsInGuild() then
            StaticPopupDialogs["TDKP_NOT_IN_GUILD"] = {
                text = "You need to be in a guild to be able to add guild members to dkp table",
                button1 = "OK",
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show ("TDKP_NOT_IN_GUILD")
        else
            local selected = "Do you want to add all players with "..selectedGuildRank.." rank to dkp table?"
            StaticPopupDialogs["TDKP_ADD_GUILD_ENTRIES"] = {
                text = selected,
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    Core:AddGuildToDKPTable(selectedGuildRank)
                    View:UpdateDKPTable()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("TDKP_ADD_GUILD_ENTRIES")
        end
    end);

end

function View:ToggleAddGuildFrame()
    AddGuildFrame:SetShown(not AddGuildFrame:IsShown());
end

function View:HideAddGuildFrame()
    AddGuildFrame:SetShown(false);
end