local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local AddGuildFrame = nil;

local ADDGUILD_FRAME_TITLE = "Add guild"

function View:CreateAddGuildFrame(parentFrame)
    AddGuildFrame = View:CreateContainerFrame("ThirtyDKP_AddGuildFrame", parentFrame, ADDGUILD_FRAME_TITLE, 370, 300);

    local ranks = DAL:GetGuildRankInfo()

    local rankDropdownInfo = L_UIDropDownMenu_CreateInfo();
	rankDropdownInfo.func = RankDropdownOnClick;

    for i=1, #ranks do
        rankDropdownInfo.text = rank[i];
        rankDropdownInfo.arg1 = i;
        rankDropdownInfo.arg2 = rankDropdownInfo.text;
        rankdDropdownInfo.checked = SelectedRaid == i;
        L_UIDropDownMenu_AddButton(raidDropdownInfo);
    end




end