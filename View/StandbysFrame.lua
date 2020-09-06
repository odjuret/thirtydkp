local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local standbysFrame = nil;

local STANDBYS_FRAME_TITLE = "Standby's"

local selectedStandbys = {};


local function UpdateStandbysListRowsTextures()
	for i, row in ipairs(standbysFrame.standbysList.scrollChild.Rows) do 
		local playerIsSelected = DAL:Table_Search(selectedStandbys, row.Standby.originalValue)
		if playerIsSelected ~= false then
            row:SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
            row:GetNormalTexture():SetAlpha(1)
        else
            row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
            row:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
            row:GetNormalTexture():SetAlpha(0.5)
        end
    end
end

local function CreateStandbyListRow(parent, id, standbys)

	local b = CreateFrame("Button", nil, parent);
	b:SetSize(standbysFrame:GetWidth()-10, Const.DKPTableRowHeight);
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	b:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
	b:GetNormalTexture():SetAlpha(0.5)
	b:GetNormalTexture():SetAllPoints(true)

	b.Standby = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.Standby:SetFontObject("GameFontHighlight")
	b.Standby:SetText(standbys[id]);
	b.Standby:SetPoint(Const.LEFT_POINT, Const.Margin, 0)
	b.Standby.originalValue = standbys[id];

	b:RegisterForClicks("AnyUp");
	b:SetScript("OnClick", function (self, button, down)
		if button == "LeftButton" then
			if not IsShiftKeyDown() then
				selectedStandbys = {}
			end
			local playerSelected = DAL:Table_Search(selectedStandbys, standbys[id]);
			if playerSelected == false then
				table.insert(selectedStandbys, standbys[id]);
			else
				table.remove(selectedStandbys, playerSelected);
			end
			UpdateStandbysListRowsTextures();
		end
	end);
	
	return b
end


local function PopulateStandbysList(parentFrame, standbys)
	parentFrame.scrollChild.Rows = {}

	for i = 1, #standbys do
		parentFrame.scrollChild.Rows[i] = CreateStandbyListRow(parentFrame.scrollChild, i, standbys)
		if i==1 then
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild, Const.TOP_LEFT_POINT, 0, -2)
		else
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild.Rows[i-1], Const.BOTTOM_LEFT_POINT)
		end
	end
end


local function CreateStandbysList()
    local standbys = DAL:GetStandbys();
    standbysFrame.standbysList = CreateFrame("ScrollFrame", 'standbysScrollFrame', standbysFrame, "UIPanelScrollFrameTemplate");
    local standbysList = standbysFrame.standbysList;
	standbysList:SetFrameStrata("HIGH");
	standbysList:SetFrameLevel(9);

	standbysList:SetSize( 130, 100 );
	standbysList:SetPoint( Const.TOP_LEFT_POINT, 10, -30 );
	standbysList.scrollBar = _G["standbysScrollFrameScrollBar"]; --fuckin xml -> lua glue magic

    standbysList.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", standbysList );
	standbysList.scrollChild:SetHeight( Const.DKPTableRowHeight*(#standbys)+3 );
    standbysList.scrollChild:SetWidth( 130 );
	standbysList.scrollChild:SetAllPoints( standbysList );
	standbysList.scrollChild.bg = standbysList.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	standbysList.scrollChild.bg:SetAllPoints(true)
	standbysList.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	standbysList:SetScrollChild( standbysList.scrollChild );

	PopulateStandbysList(standbysList, standbys);
end

function View:CreateStandbysFrame(parentFrame)
	standbysFrame = View:CreateContainerFrame("ThirtyDKP_StandbysFrame", parentFrame, STANDBYS_FRAME_TITLE, 170, 190);

    -- Buttons
    
    standbysFrame.addStandbyBtn = CreateFrame("Button", nil, standbysFrame, "GameMenuButtonTemplate");
    standbysFrame.addStandbyBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, standbysFrame, Const.BOTTOM_RIGHT_POINT, -10, 10);
    standbysFrame.addStandbyBtn:SetSize(110, Const.ButtonHeight);
    standbysFrame.addStandbyBtn:SetText("Add");
    standbysFrame.addStandbyBtn:SetNormalFontObject("GameFontNormal");
    standbysFrame.addStandbyBtn:SetHighlightFontObject("GameFontHighlight");
    View:AttachHoverOverTooltipAndOnclick(standbysFrame.addStandbyBtn, "Add Standby", "Adds selected members from the DKP table on the left into standby list above.", function(self, button, down)
        local selectedPlayers = View:GetSelectedDKPTableEntries();
        if #selectedPlayers < 1 then
            Core:Print("Please select players to add to standby list from the DKP table to the left")
            return;
        end
        
        for i, selectedPlayer in ipairs(selectedPlayers) do
            DAL:AddStandby(selectedPlayer)
        end
        View:UpdateStandbysFrame()
    end);

    standbysFrame.removeStandbyBtn = CreateFrame("Button", nil, standbysFrame, "GameMenuButtonTemplate");
    standbysFrame.removeStandbyBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, standbysFrame.addStandbyBtn, Const.TOP_RIGHT_POINT, 0, 0);
    standbysFrame.removeStandbyBtn:SetSize(110, Const.ButtonHeight);
    standbysFrame.removeStandbyBtn:SetText("Remove");
    standbysFrame.removeStandbyBtn:SetNormalFontObject("GameFontNormal");
    standbysFrame.removeStandbyBtn:SetHighlightFontObject("GameFontHighlight");
    View:AttachHoverOverTooltipAndOnclick(standbysFrame.removeStandbyBtn, "Remove Standby", "Removes selected members from the standby list above.", function(self, button, down)
        if #selectedStandbys < 1 then
            Core:Print("Please select players to remove from the standby list above")
            return;
        end
        for i, selectedStandby in ipairs(selectedStandbys) do
            DAL:RemoveStandby(selectedStandby)
        end
        View:UpdateStandbysFrame()
    end);

    CreateStandbysList()
end

function View:UpdateStandbysFrame()
	local tdkpMainFrame = View:GetMainFrame()

	standbysFrame:Hide()
	standbysFrame:SetParent(nil)
	standbysFrame = nil;

	View:CreateStandbysFrame(tdkpMainFrame)
	standbysFrame:Show()
end

function View:ToggleStandbysFrame()
    standbysFrame:SetShown(not standbysFrame:IsShown());
end

function View:HideStandbysFrame()
    standbysFrame:SetShown(false);
end