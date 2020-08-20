local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local dkpAdminsFrame = nil;

local DKPADMINS_FRAME_TITLE = "Admins"

local selectedDKPAdmins = {};


local function UpdateDKPAdminsListRowsTextures()
	for i, row in ipairs(dkpAdminsFrame.AdminsList.scrollChild.Rows) do 
		local playerIsSelected = DAL:Table_Search(selectedDKPAdmins, row.DKPAdmin.originalValue)
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

local function CreateDKPAdminListRow(parent, id, dkpAdmins)

	local b = CreateFrame("Button", nil, parent);
	b:SetSize(dkpAdminsFrame:GetWidth()-10, Const.DKPTableRowHeight);
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	b:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
	b:GetNormalTexture():SetAlpha(0.5)
	b:GetNormalTexture():SetAllPoints(true)

	b.DKPAdmin = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPAdmin:SetFontObject("GameFontHighlight")
	b.DKPAdmin:SetText(dkpAdmins[id]);
	b.DKPAdmin:SetPoint(Const.LEFT_POINT, Const.Margin, 0)
	b.DKPAdmin.originalValue = dkpAdmins[id];

	b:RegisterForClicks("AnyUp");
	b:SetScript("OnClick", function (self, button, down)
		if button == "LeftButton" then
			if not IsShiftKeyDown() then
				selectedDKPAdmins = {}
			end
			local playerSelected = DAL:Table_Search(selectedDKPAdmins, dkpAdmins[id]);
			if playerSelected == false then
				table.insert(selectedDKPAdmins, dkpAdmins[id]);
			else
				table.remove(selectedDKPAdmins, playerSelected);
			end
			UpdateDKPAdminsListRowsTextures();
		end
	end);
	
	return b
end


local function PopulateDKPAdminsList(parentFrame, dkpAdmins)
	parentFrame.scrollChild.Rows = {}

	for i = 1, #dkpAdmins do
		parentFrame.scrollChild.Rows[i] = CreateDKPAdminListRow(parentFrame.scrollChild, i, dkpAdmins)
		if i==1 then
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild, Const.TOP_LEFT_POINT, 0, -2)
		else
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild.Rows[i-1], Const.BOTTOM_LEFT_POINT)
		end
	end
end


local function CreateDKPAdminsList()
    local dkpAdmins = DAL:GetAddonAdmins();
    dkpAdminsFrame.AdminsList = CreateFrame("ScrollFrame", 'DKPAdminsScrollFrame', dkpAdminsFrame, "UIPanelScrollFrameTemplate");
    local adminsList = dkpAdminsFrame.AdminsList;
	adminsList:SetFrameStrata("HIGH");
	adminsList:SetFrameLevel(9);

	adminsList:SetSize( 130, 100 );
	adminsList:SetPoint( Const.TOP_LEFT_POINT, 10, -30 );
	adminsList.scrollBar = _G["DKPAdminsScrollFrameScrollBar"]; --fuckin xml -> lua glue magic

    adminsList.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", adminsList );
	adminsList.scrollChild:SetHeight( Const.DKPTableRowHeight*(#dkpAdmins)+3 );
    adminsList.scrollChild:SetWidth( 130 );
	adminsList.scrollChild:SetAllPoints( adminsList );
	adminsList.scrollChild.bg = adminsList.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	adminsList.scrollChild.bg:SetAllPoints(true)
	adminsList.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	adminsList:SetScrollChild( adminsList.scrollChild );

	PopulateDKPAdminsList(adminsList, dkpAdmins);
end

function View:CreateDKPAdminsFrame(parentFrame)
	dkpAdminsFrame = View:CreateContainerFrame("ThirtyDKP_AdminsFrame", parentFrame, DKPADMINS_FRAME_TITLE, 170, 190);

    -- Buttons
    
    dkpAdminsFrame.addAdminsBtn = CreateFrame("Button", nil, dkpAdminsFrame, "GameMenuButtonTemplate");
    dkpAdminsFrame.addAdminsBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, dkpAdminsFrame, Const.BOTTOM_RIGHT_POINT, -10, 10);
    dkpAdminsFrame.addAdminsBtn:SetSize(110, Const.ButtonHeight);
    dkpAdminsFrame.addAdminsBtn:SetText("Promote Admins");
    dkpAdminsFrame.addAdminsBtn:SetNormalFontObject("GameFontNormal");
    dkpAdminsFrame.addAdminsBtn:SetHighlightFontObject("GameFontHighlight");
    dkpAdminsFrame.addAdminsBtn:RegisterForClicks("AnyUp");
    dkpAdminsFrame.addAdminsBtn:SetScript("OnClick", function (self, button, down)
        local selectedPlayers = View:GetSelectedDKPTableEntries();
        if #selectedPlayers < 1 then
            Core:Print("Please select players to promote from the DKP table to the left")
            return;
        end
        
        for i, selectedPlayer in ipairs(selectedPlayers) do
            DAL:AddAddonAdmin(selectedPlayer)
        end
        View:UpdateDKPAdminsFrame()
    end);

    dkpAdminsFrame.removeAdminsBtn = CreateFrame("Button", nil, dkpAdminsFrame, "GameMenuButtonTemplate");
    dkpAdminsFrame.removeAdminsBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, dkpAdminsFrame.addAdminsBtn, Const.TOP_RIGHT_POINT, 0, 0);
    dkpAdminsFrame.removeAdminsBtn:SetSize(110, Const.ButtonHeight);
    dkpAdminsFrame.removeAdminsBtn:SetText("Demote Admins");
    dkpAdminsFrame.removeAdminsBtn:SetNormalFontObject("GameFontNormal");
    dkpAdminsFrame.removeAdminsBtn:SetHighlightFontObject("GameFontHighlight");
    dkpAdminsFrame.removeAdminsBtn:RegisterForClicks("AnyUp");
    dkpAdminsFrame.removeAdminsBtn:SetScript("OnClick", function (self, button, down)
        if #selectedDKPAdmins < 1 then
            Core:Print("Please select admins to demote from the admin list")
            return;
        end
        for i, selectedAdmin in ipairs(selectedDKPAdmins) do
            DAL:RemoveAddonAdmin(selectedAdmin)
        end
        View:UpdateDKPAdminsFrame()
    end);

    CreateDKPAdminsList()
end

function View:UpdateDKPAdminsFrame()
	local mainFrame = View:GetMainFrame()

	dkpAdminsFrame:Hide()
	dkpAdminsFrame:SetParent(nil)
	dkpAdminsFrame = nil;

	View:CreateDKPAdminsFrame(mainFrame)
	dkpAdminsFrame:Show()
end

function View:ToggleDKPAdminsFrame()
    dkpAdminsFrame:SetShown(not dkpAdminsFrame:IsShown());
end

function View:HideDKPAdminsFrame()
    dkpAdminsFrame:SetShown(false);
end