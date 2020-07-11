local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local TdkpAdminsFrame = nil;

local TDKPADMINS_FRAME_TITLE = "Admins"

local selectedDKPAdmins = {};


local function UpdateDKPAdminsListRowsTextures()
	for i, row in ipairs(TdkpAdminsFrame.AdminsList.scrollChild.Rows) do 
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
	b:SetSize(TdkpAdminsFrame:GetWidth()-10, Const.DKPTableRowHeight);
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
    TdkpAdminsFrame.AdminsList = CreateFrame("ScrollFrame", 'DKPAdminsScrollFrame', TdkpAdminsFrame, "UIPanelScrollFrameTemplate");
    local adminsList = TdkpAdminsFrame.AdminsList;
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

function View:CreateTdkpAdminsFrame(parentFrame)
	TdkpAdminsFrame = CreateFrame("Frame", "ThirtyDKP_OptionsFrame", parentFrame, "TooltipBorderedFrameTemplate"); -- Todo: make mainframe owner??
	TdkpAdminsFrame:SetShown(false);
	TdkpAdminsFrame:SetSize(170, 190);
	TdkpAdminsFrame:SetFrameStrata("HIGH");
	TdkpAdminsFrame:SetPoint(Const.TOP_LEFT_POINT, parentFrame, Const.TOP_RIGHT_POINT, 0, 0); -- point, relative frame, relative point on relative frame
    TdkpAdminsFrame:EnableMouse(true);

    -- title
    local title = TdkpAdminsFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
    title:SetFontObject("GameFontNormal");
    title:SetPoint(Const.TOP_LEFT_POINT, TdkpAdminsFrame, Const.TOP_LEFT_POINT, 15, -10);
    title:SetText(TDKPADMINS_FRAME_TITLE);

    -- Buttons
    TdkpAdminsFrame.closeBtn = CreateFrame("Button", nil, TdkpAdminsFrame, "UIPanelCloseButton")
    TdkpAdminsFrame.closeBtn:SetPoint(Const.TOP_RIGHT_POINT, TdkpAdminsFrame, Const.TOP_RIGHT_POINT)
    
    TdkpAdminsFrame.addAdminsBtn = CreateFrame("Button", nil, TdkpAdminsFrame, "GameMenuButtonTemplate");
    TdkpAdminsFrame.addAdminsBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, TdkpAdminsFrame, Const.BOTTOM_RIGHT_POINT, -10, 10);
    TdkpAdminsFrame.addAdminsBtn:SetSize(110, Const.ButtonHeight);
    TdkpAdminsFrame.addAdminsBtn:SetText("Promote Admins");
    TdkpAdminsFrame.addAdminsBtn:SetNormalFontObject("GameFontNormal");
    TdkpAdminsFrame.addAdminsBtn:SetHighlightFontObject("GameFontHighlight");
    TdkpAdminsFrame.addAdminsBtn:RegisterForClicks("AnyUp");
    TdkpAdminsFrame.addAdminsBtn:SetScript("OnClick", function (self, button, down)
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

    TdkpAdminsFrame.removeAdminsBtn = CreateFrame("Button", nil, TdkpAdminsFrame, "GameMenuButtonTemplate");
    TdkpAdminsFrame.removeAdminsBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, TdkpAdminsFrame.addAdminsBtn, Const.TOP_RIGHT_POINT, 0, 0);
    TdkpAdminsFrame.removeAdminsBtn:SetSize(110, Const.ButtonHeight);
    TdkpAdminsFrame.removeAdminsBtn:SetText("Demote Admins");
    TdkpAdminsFrame.removeAdminsBtn:SetNormalFontObject("GameFontNormal");
    TdkpAdminsFrame.removeAdminsBtn:SetHighlightFontObject("GameFontHighlight");
    TdkpAdminsFrame.removeAdminsBtn:RegisterForClicks("AnyUp");
    TdkpAdminsFrame.removeAdminsBtn:SetScript("OnClick", function (self, button, down)
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

	TdkpAdminsFrame:Hide()
	TdkpAdminsFrame:SetParent(nil)
	TdkpAdminsFrame = nil;

	View:CreateTdkpAdminsFrame(mainFrame)
	TdkpAdminsFrame:Show()
end

function View:ToggleTdkpAdminsFrame()
    TdkpAdminsFrame:SetShown(not TdkpAdminsFrame:IsShown());
end

function View:HideTdkpAdminsFrame()
    TdkpAdminsFrame:SetShown(false);
end