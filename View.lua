local addonName, addonNamespace = ...

-- Initializing the view
addonNamespace.View = {}
local View = addonNamespace.View;

-- Main addon window
View.ThirtyDKP_MainFrame = nil;
View.ThirtyDKP_OptionsFrame = nil;
View.ThirtyDKP_UIInitialized = false;
local MainFrame = View.ThirtyDKP_MainFrame

-- UI anchor point constants (blizz should have these somewhere??)
local CENTER_POINT = "CENTER"
local TOP_POINT = "TOP"
local TOP_LEFT_POINT = "TOPLEFT"
local TOP_RIGHT_POINT = "TOPRIGHT"
local LEFT_POINT = "LEFT"
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


local function Create_DKPTableRow(parent, id)
	local b = CreateFrame("Button", nil, MainFrame.scrollChild);
	b:SetSize(DKPTableWidth-100, DKPTableRowHeight);
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
	b:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
	b:GetNormalTexture():SetAlpha(0.5)
	b:GetNormalTexture():SetAllPoints(true)
	--b.bg = b:CreateTexture(nil, "BACKGROUND")
	--b.bg:SetAllPoints(true)
	--b.bg:SetColorTexture(0.2, 0.4, 0.8, 0.2)
    --b:SetText("TestTesT");
    --b:SetNormalFontObject("GameFontNormal");
	--b:SetHighlightFontObject("GameFontHighlight");
	b.DKPInfo = {}
	b.DKPInfo.PlayerName = b:CreateFontString(nil, OVERLAY_LAYER)
	b.DKPInfo.PlayerName:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerName:SetText(tostring(addonNamespace.Core.DKPTableCopy[id].player));
	b.DKPInfo.PlayerName:SetPoint("LEFT", 30, 0)

	b.DKPInfo.PlayerClass = b:CreateFontString(nil, OVERLAY_LAYER)
	b.DKPInfo.PlayerClass:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerClass:SetText(tostring(addonNamespace.Core.DKPTableCopy[id].class));
	b.DKPInfo.PlayerClass:SetPoint("CENTER")

	b.DKPInfo.CurrentDKP = b:CreateFontString(nil, OVERLAY_LAYER)
	b.DKPInfo.CurrentDKP:SetFontObject("GameFontHighlight")
	b.DKPInfo.CurrentDKP:SetText(tostring(addonNamespace.Core.DKPTableCopy[id].dkp));
	b.DKPInfo.CurrentDKP:SetPoint("RIGHT", -80, 0)
	return b
end


local function Populate_DKPTable()
	MainFrame.scrollChild.Rows = {}
	for i = 1, addonNamespace.Core.DKPTableNumRows do
		MainFrame.scrollChild.Rows[i] = Create_DKPTableRow(MainFrame.scrollChild, i)
		if i==1 then
			MainFrame.scrollChild.Rows[i]:SetPoint("TOPLEFT", MainFrame.scrollChild, "TOPLEFT", 0, -2)
		else  
			MainFrame.scrollChild.Rows[i]:SetPoint("TOPLEFT", MainFrame.scrollChild.Rows[i-1], "BOTTOMLEFT")
		end
	end
end


local function Create_DKPTable()
	-- "Container" frame that clips out its child frame "excess" content.
	MainFrame.DKPTable = CreateFrame("ScrollFrame", 'DKPTableScrollFrame', MainFrame, "UIPanelScrollFrameTemplate");
	local scrollFrame = MainFrame.DKPTable
	scrollFrame:SetSize(DKPTableWidth, addonNamespace.Core.DKPTableNumRows*12);	
	scrollFrame.scrollBar = _G["DKPTableScrollFrameScrollBar"]; --fuckin xml -> lua glue magic 
	scrollFrame:SetPoint( TOP_LEFT_POINT, 10, -30 );
	scrollFrame:SetPoint( BOTTOMRIGHT_POINT, -120, 10 );
	
	-- Child frame which holds all the content being scrolled through.
    MainFrame.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", scrollFrame );
	MainFrame.scrollChild:SetHeight( DKPTableRowHeight*addonNamespace.Core.DKPTableNumRows+3 );
    MainFrame.scrollChild:SetWidth( scrollFrame:GetWidth() );
	MainFrame.scrollChild:SetAllPoints( scrollFrame );
	MainFrame.scrollChild.bg = MainFrame.scrollChild:CreateTexture(nil, "BACKGROUND")
	MainFrame.scrollChild.bg:SetAllPoints(true)
	MainFrame.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	scrollFrame:SetScrollChild( MainFrame.scrollChild );

	Populate_DKPTable()
end

local function Create_OptionsFrame()
	OptionsFrame = CreateFrame('Frame', 'ThirtyDKP_OptionsFrame', UIParent, "UIPanelDialogTemplate");
	OptionsFrame:SetShown(false);
	OptionsFrame:SetSize(500, 500);
	OptionsFrame:SetFrameStrata("HIGH");
	OptionsFrame:SetPoint(TOP_LEFT_POINT, MainFrame, TOP_RIGHT_POINT, 0, 0); -- point, relative frame, relative point on relative frame
	OptionsFrame:EnableMouse(true);
	OptionsFrame:SetMovable(true);
	OptionsFrame:RegisterForDrag("LeftButton");
	OptionsFrame:SetScript("OnDragStart", function()
		MainFrame:StartMoving();
		OptionsFrame:StartMoving();
	end);
	OptionsFrame:SetScript("OnDragStop", function()
		MainFrame:StopMovingOrSizing();
		OptionsFrame:StopMovingOrSizing();
	end);
	OptionsFrame:SetScript("OnShow", function()
		local point, relativeTo, relativePoint, xOffset, yOffset = MainFrame:GetPoint();
		MainFrame:SetPoint(point, relativeTo, relativePoint, xOffset - MainFrame:GetWidth()/2, yOffset);
	end);
	OptionsFrame:SetScript("OnHide", function()
		local point, relativeTo, relativePoint, xOffset, yOffset = MainFrame:GetPoint();
		MainFrame:SetPoint(point, relativeTo, relativePoint, xOffset + MainFrame:GetWidth()/2, yOffset);
	end);

	 -- title
	 local title = OptionsFrame:CreateFontString(nil, OVERLAY_LAYER);
	 title:SetFontObject("GameFontNormal");
	 title:ClearAllPoints();
	 title:SetPoint(TOP_LEFT_POINT, OptionsFrame, TOP_LEFT_POINT, 15, -10);
	 title:SetText(OPTIONS_FRAME_TITLE);
end


local function Create_MainFrame()
	View.ThirtyDKP_MainFrame = CreateFrame('Frame', 'ThirtyDKP_MainFrame', UIParent, "UIPanelDialogTemplate");
	MainFrame = View.ThirtyDKP_MainFrame;

	MainFrame:SetShown(false);
    MainFrame:SetSize(DKPTableWidth + 30, DKPTableRowHeight*15); -- width, height
	MainFrame:SetPoint(CENTER_POINT, UIParent, CENTER_POINT, 0, 60); -- point, relative frame, relative point on relative frame
	MainFrame:SetFrameStrata("HIGH");
	MainFrame:SetMovable(true);
	MainFrame:EnableMouse(true);
	MainFrame:RegisterForDrag("LeftButton");
	MainFrame:SetScript("OnDragStart", MainFrame.StartMoving);
	MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing);
	MainFrame:SetScript("OnHide", function(self)
		if OptionsFrame then
			OptionsFrame:SetShown(false);
		end
	end);

    -- title
    ThirtyDKP_UI_MainFrameTitleBG = MainFrame:CreateFontString(nil, OVERLAY_LAYER);
	ThirtyDKP_UI_MainFrameTitleBG:SetFontObject("GameFontNormal");
	ThirtyDKP_UI_MainFrameTitleBG:ClearAllPoints();
    ThirtyDKP_UI_MainFrameTitleBG:SetPoint(TOP_LEFT_POINT, ThirtyDKP_MainFrame, TOP_LEFT_POINT, 15, -10);
    ThirtyDKP_UI_MainFrameTitleBG:SetText(MAIN_FRAME_TITLE);

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
	Create_DKPTable();
end

function View:InitUI()
	Create_MainFrame();
	Create_OptionsFrame();
	View.ThirtyDKP_UIInitialized = true;
end