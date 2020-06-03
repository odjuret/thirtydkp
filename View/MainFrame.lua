local addonName, ThirtyDKP = ...

local View = ThirtyDKP.View;

-- Main addon window
local OptionsFrame = nil;
local Initialized = false;
local MainFrame = nil;

-- UI anchor point constants (blizz should have these somewhere??)
-- Or maybe move these to some addon scope?
local CENTER_POINT = "CENTER"
local TOP_POINT = "TOP"
local TOP_LEFT_POINT = "TOPLEFT"
local TOP_RIGHT_POINT = "TOPRIGHT"
local LEFT_POINT = "LEFT"
local RIGHT_POINT = "RIGHT"
local BOTTOMRIGHT_POINT = "BOTTOMRIGHT"
local BOTTOMLEFT_POINT = "BOTTOMLEFT"

-- Layer levels (blizz should have these somewhere??)
local BACKGROUND_LAYER = "BACKGROUND"   -- Level 0. Place the background of your frame here.
local BORDER_LAYER = "BORDER"           -- Level 1. Place the artwork of your frame here .
local ARTWORK_LAYER = "ARTWORK"         -- Level 2. Place the artwork of your frame here.
local OVERLAY_LAYER = "OVERLAY"         -- Level 3. Place your text, objects, and buttons in this level.
local HIGHLIGHT_LAYER = "HIGHLIGHT"     -- Level 4. Place your text, objects, and buttons in this level.

-- Titles related constants
local MAIN_FRAME_TITLE = "Thirty DKP"
local OPTIONS_FRAME_TITLE = "Options"


-- Sizes
local DKPTableWidth, DKPTableRowHeight = 500, 18;

local function CreateDKPTableRow(parent, id)
	local b = CreateFrame("Button", nil, MainFrame.scrollChild);
	b:SetSize(DKPTableWidth-100, DKPTableRowHeight);
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
	b:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
	b:GetNormalTexture():SetAlpha(0.5)
	b:GetNormalTexture():SetAllPoints(true)

	b.DKPInfo = {}
	b.DKPInfo.PlayerName = b:CreateFontString(nil, OVERLAY_LAYER)
	b.DKPInfo.PlayerName:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerName:SetText(tostring(ThirtyDKP.DAL.DKPTableCopy[id].player));
	b.DKPInfo.PlayerName:SetPoint(LEFT_POINT, 30, 0)

	b.DKPInfo.PlayerClass = b:CreateFontString(nil, OVERLAY_LAYER)
	b.DKPInfo.PlayerClass:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerClass:SetText(tostring(ThirtyDKP.DAL.DKPTableCopy[id].class));
	b.DKPInfo.PlayerClass:SetPoint(CENTER_POINT)

	b.DKPInfo.CurrentDKP = b:CreateFontString(nil, OVERLAY_LAYER)
	b.DKPInfo.CurrentDKP:SetFontObject("GameFontHighlight")
	b.DKPInfo.CurrentDKP:SetText(tostring(ThirtyDKP.DAL.DKPTableCopy[id].dkp));
	b.DKPInfo.CurrentDKP:SetPoint(RIGHT_POINT, -80, 0)
	return b
end


local function PopulateDKPTable()
	MainFrame.scrollChild.Rows = {}
	for i = 1, ThirtyDKP.DAL.DKPTableNumRows do
		MainFrame.scrollChild.Rows[i] = CreateDKPTableRow(MainFrame.scrollChild, i)
		if i==1 then
			MainFrame.scrollChild.Rows[i]:SetPoint(TOP_LEFT_POINT, MainFrame.scrollChild, TOP_LEFT_POINT, 0, -2)
		else
			MainFrame.scrollChild.Rows[i]:SetPoint(TOP_LEFT_POINT, MainFrame.scrollChild.Rows[i-1], BOTTOMLEFT_POINT)
		end
	end
end


local function CreateDKPTable()
	-- "Container" frame that clips out its child frame "excess" content.
	MainFrame.DKPTable = CreateFrame("ScrollFrame", 'DKPTableScrollFrame', MainFrame, "UIPanelScrollFrameTemplate");
	local scrollFrame = MainFrame.DKPTable
	scrollFrame:SetSize(DKPTableWidth, ThirtyDKP.DAL.DKPTableNumRows*12);
	scrollFrame.scrollBar = _G["DKPTableScrollFrameScrollBar"]; --fuckin xml -> lua glue magic
	scrollFrame:SetPoint( TOP_LEFT_POINT, 10, -30 );
	scrollFrame:SetPoint( BOTTOMRIGHT_POINT, -120, 10 );

	-- Child frame which holds all the content being scrolled through.
    MainFrame.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", scrollFrame );
	MainFrame.scrollChild:SetHeight( DKPTableRowHeight*ThirtyDKP.DAL.DKPTableNumRows+3 );
    MainFrame.scrollChild:SetWidth( scrollFrame:GetWidth() );
	MainFrame.scrollChild:SetAllPoints( scrollFrame );
	MainFrame.scrollChild.bg = MainFrame.scrollChild:CreateTexture(nil, BACKGROUND_LAYER)
	MainFrame.scrollChild.bg:SetAllPoints(true)
	MainFrame.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	scrollFrame:SetScrollChild( MainFrame.scrollChild );

	PopulateDKPTable()
end

local function CreateOptionsFrame()
	OptionsFrame = CreateFrame('Frame', 'ThirtyDKP_OptionsFrame', UIParent, "UIPanelDialogTemplate");
	OptionsFrame:SetShown(false);
	OptionsFrame:SetSize(500, 500);
	OptionsFrame:SetFrameStrata("HIGH");
	OptionsFrame:SetClampedToScreen(true);
	OptionsFrame:SetPoint(TOP_LEFT_POINT, MainFrame, TOP_RIGHT_POINT, 0, 0); -- point, relative frame, relative point on relative frame
	OptionsFrame:EnableMouse(true);

	 -- title
	 local title = OptionsFrame:CreateFontString(nil, OVERLAY_LAYER);
	 title:SetFontObject("GameFontNormal");
	 title:ClearAllPoints();
	 title:SetPoint(TOP_LEFT_POINT, OptionsFrame, TOP_LEFT_POINT, 15, -10);
	 title:SetText(OPTIONS_FRAME_TITLE);

	 -- Buttons
	 OptionsFrame.addRaidToTableBtn = CreateFrame("Button", nil, OptionsFrame, "GameMenuButtonTemplate");
	 OptionsFrame.addRaidToTableBtn:SetPoint(BOTTOMLEFT_POINT, OptionsFrame, BOTTOMLEFT_POINT, 10, 10);
	 OptionsFrame.addRaidToTableBtn:SetSize(80, 30);
	 OptionsFrame.addRaidToTableBtn:SetText("Add Raid");
	 OptionsFrame.addRaidToTableBtn:SetNormalFontObject("GameFontNormal");
	 OptionsFrame.addRaidToTableBtn:SetHighlightFontObject("GameFontHighlight");
	 OptionsFrame.addRaidToTableBtn:RegisterForClicks("AnyUp");
	 
	 View:AttachAddRaidToTableScripts(OptionsFrame.addRaidToTableBtn)
end


local function CreateMainFrame()
	MainFrame = CreateFrame('Frame', 'ThirtyDKP_MainFrame', UIParent, "UIPanelDialogTemplate");
	MainFrame:SetShown(false);
    MainFrame:SetSize(DKPTableWidth + 30, DKPTableRowHeight*15); -- width, height
	MainFrame:SetPoint(CENTER_POINT, UIParent, CENTER_POINT, 0, 60); -- point, relative frame, relative point on relative frame
	MainFrame:SetFrameStrata("HIGH");
	MainFrame:SetClampedToScreen(true);
	MainFrame:SetMovable(true);
	MainFrame:EnableMouse(true);
	MainFrame:RegisterForDrag("LeftButton");
	MainFrame:SetScript("OnDragStart", MainFrame.StartMoving);
	MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing);
	MainFrame:SetScript("OnHide", function(self)
		OptionsFrame:SetShown(false);
	end);

    -- title
    ThirtyDKP_MainFrameTitleBG = MainFrame:CreateFontString(nil, OVERLAY_LAYER);
	ThirtyDKP_MainFrameTitleBG:SetFontObject("GameFontNormal");
	ThirtyDKP_MainFrameTitleBG:ClearAllPoints();
    ThirtyDKP_MainFrameTitleBG:SetPoint(TOP_LEFT_POINT, ThirtyDKP_MainFrame, TOP_LEFT_POINT, 15, -10);
    ThirtyDKP_MainFrameTitleBG:SetText(MAIN_FRAME_TITLE);

    -- Buttons
    MainFrame.optionsButton = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
    MainFrame.optionsButton:SetPoint(BOTTOMRIGHT_POINT, MainFrame, BOTTOMRIGHT_POINT, -10, 10);
    MainFrame.optionsButton:SetSize(80, 30);
    MainFrame.optionsButton:SetText("Options");
    MainFrame.optionsButton:SetNormalFontObject("GameFontNormal");
	MainFrame.optionsButton:SetHighlightFontObject("GameFontHighlight");
	MainFrame.optionsButton:RegisterForClicks("AnyUp");
	MainFrame.optionsButton:SetScript("OnClick", function (self, button, down)
		OptionsFrame:SetShown(not OptionsFrame:IsShown());
	end);

	-- Create other frames
	CreateDKPTable();
end


function View:OpenMainFrame()
	MainFrame:SetShown(true);
end

function View:IsInitialized()
	return Initialized;
end

function View:Initialize()
	if Initialized then return end

	CreateMainFrame();
	CreateOptionsFrame();
	Initialized = true;
end