local addonName, ThirtyDKP = ...

local View = ThirtyDKP.View;
local Const = ThirtyDKP.View.Constants;

-- Main addon window
local Initialized = false;
local MainFrame = nil;


-- Titles related constants
local MAIN_FRAME_TITLE = "Thirty DKP"


local function CreateMainFrame()
	MainFrame = CreateFrame('Frame', 'ThirtyDKP_MainFrame', UIParent, "UIPanelDialogTemplate");
	MainFrame:SetShown(false);
    MainFrame:SetSize(Const.DKPTableWidth + 30, Const.DKPTableRowHeight*15); -- width, height
	MainFrame:SetPoint(Const.CENTER_POINT, UIParent, Const.CENTER_POINT, 0, 60); -- point, relative frame, relative point on relative frame
	MainFrame:SetFrameStrata("HIGH");
	MainFrame:SetFrameLevel(8);
	tinsert(UISpecialFrames, MainFrame:GetName()); -- Sets frame to close on "Escape"

	MainFrame:SetClampedToScreen(true);
	MainFrame:SetMovable(true);
	MainFrame:EnableMouse(true);
	MainFrame:RegisterForDrag("LeftButton");
	MainFrame:SetScript("OnDragStart", MainFrame.StartMoving);
	MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing);
	MainFrame:SetScript("OnHide", function(self)
		View:HideOptionsFrame()
	end);

    -- title
    ThirtyDKP_MainFrameTitleBG = MainFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	ThirtyDKP_MainFrameTitleBG:SetFontObject("GameFontNormal");
	ThirtyDKP_MainFrameTitleBG:ClearAllPoints();
    ThirtyDKP_MainFrameTitleBG:SetPoint(Const.TOP_LEFT_POINT, ThirtyDKP_MainFrame, Const.TOP_LEFT_POINT, 15, -10);
    ThirtyDKP_MainFrameTitleBG:SetText(MAIN_FRAME_TITLE);

    -- Buttons
    MainFrame.optionsButton = CreateFrame("Button", nil, MainFrame, "GameMenuButtonTemplate");
    MainFrame.optionsButton:SetPoint(Const.BOTTOMRIGHT_POINT, MainFrame, Const.BOTTOMRIGHT_POINT, -10, 10);
    MainFrame.optionsButton:SetSize(80, 30);
    MainFrame.optionsButton:SetText("Options");
    MainFrame.optionsButton:SetNormalFontObject("GameFontNormal");
	MainFrame.optionsButton:SetHighlightFontObject("GameFontHighlight");
	MainFrame.optionsButton:RegisterForClicks("AnyUp");
	MainFrame.optionsButton:SetScript("OnClick", function (self, button, down)
		View:ToggleOptionsFrame()
	end);

end

function View:GetMainFrame()
	return MainFrame;
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
	View:CreateDKPTable(MainFrame);
	View:CreateOptionsFrame(MainFrame);
	View:CreateBidAnnounceFrame();
	View:ToggleBidAnnounceFrame()
	Initialized = true;
end