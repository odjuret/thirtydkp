local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local TdkpAltsFrame = nil;
local TdkpNewAltFrame = nil;

local ALT_FRAME_TITLE = "Alts"
local NEW_ALT_FRAME_TITLE = "New Alt"

local selectedAlts = {};



local function CreateNewAltFrame(parentFrame)
	TdkpNewAltFrame = View:CreateContainerFrame("ThirtyDKP_NewAltFrame", parentFrame, NEW_ALT_FRAME_TITLE, 150, 130);

	local wrapper = CreateFrame("Frame", nil, TdkpNewAltFrame, nil);
	wrapper:SetSize(110, 50);
	wrapper:SetPoint(Const.TOP_LEFT_POINT, TdkpNewAltFrame, Const.TOP_LEFT_POINT, Const.Margin, -35);

	TdkpNewAltFrame.mainNameLabel = TdkpNewAltFrame:CreateFontString(nil, OVERLAY_LAYER);
	TdkpNewAltFrame.mainNameLabel:SetFontObject("GameFontNormal");
	TdkpNewAltFrame.mainNameLabel:SetText("Main:");
	TdkpNewAltFrame.mainNameLabel:SetPoint(Const.TOP_LEFT_POINT, wrapper, Const.TOP_LEFT_POINT, 0, 0);

	TdkpNewAltFrame.mainName = TdkpNewAltFrame:CreateFontString(nil, OVERLAY_LAYER);
	TdkpNewAltFrame.mainName:SetFontObject("GameFontNormal");
	TdkpNewAltFrame.mainName:SetText("");
	TdkpNewAltFrame.mainName:SetPoint(Const.TOP_LEFT_POINT, TdkpNewAltFrame.mainNameLabel, Const.TOP_RIGHT_POINT, 5, 0);

	TdkpNewAltFrame.altNameInput = View:CreateTextInputFrame(wrapper, "Alt:", "", nil);
	TdkpNewAltFrame.altNameInput:SetPoint(Const.TOP_LEFT_POINT, TdkpNewAltFrame.mainNameLabel, Const.BOTTOM_LEFT_POINT, 0, -5);

	TdkpNewAltFrame.cancelBtn = CreateFrame("Button", nil, TdkpNewAltFrame, "GameMenuButtonTemplate");
    TdkpNewAltFrame.cancelBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, TdkpNewAltFrame, Const.BOTTOM_RIGHT_POINT, -10, 10);
    TdkpNewAltFrame.cancelBtn:SetSize(110, Const.ButtonHeight);
    TdkpNewAltFrame.cancelBtn:SetText("Cancel");
    TdkpNewAltFrame.cancelBtn:SetNormalFontObject("GameFontNormal");
    TdkpNewAltFrame.cancelBtn:SetHighlightFontObject("GameFontHighlight");
    TdkpNewAltFrame.cancelBtn:RegisterForClicks("AnyUp");
	TdkpNewAltFrame.cancelBtn:SetScript("OnClick", function (self, button, down)
		TdkpNewAltFrame:Hide();
    end);

	TdkpNewAltFrame.addAltBtn = CreateFrame("Button", nil, TdkpNewAltFrame, "GameMenuButtonTemplate");
    TdkpNewAltFrame.addAltBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, TdkpNewAltFrame.cancelBtn, Const.TOP_RIGHT_POINT, 0, 0);
    TdkpNewAltFrame.addAltBtn:SetSize(110, Const.ButtonHeight);
    TdkpNewAltFrame.addAltBtn:SetText("Add");
    TdkpNewAltFrame.addAltBtn:SetNormalFontObject("GameFontNormal");
    TdkpNewAltFrame.addAltBtn:SetHighlightFontObject("GameFontHighlight");
    TdkpNewAltFrame.addAltBtn:RegisterForClicks("AnyUp");
	TdkpNewAltFrame.addAltBtn:SetScript("OnClick", function (self, button, down)
		local altName = TdkpNewAltFrame.altNameInput.input:GetText();
		altName = string.gsub(altName, "%s+", "");
		local mainName = TdkpNewAltFrame.mainName:GetText();
		if #altName == 0 then
			Core:Print("Alt name cannot be empty!");
		else
			if DAL:AddAlt(altName, mainName) then
				View:UpdateAltsFrame();
				TdkpNewAltFrame:Hide();
			else
				Core:Print("Alt with that name already exists");
			end
		end
    end);
end


local function OpenNewAltFrame(player)
	TdkpNewAltFrame.mainName:SetText(player);
	TdkpNewAltFrame.altNameInput.input:SetText("");
	TdkpNewAltFrame:Show();
end


local function UpdateAltListRowsTextures()
	for i, row in ipairs(TdkpAltsFrame.altList.scrollChild.Rows) do 
		local playerIsSelected = DAL:Table_Search(selectedAlts, row.Alt.originalValue)
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


local function CreateAltListRow(parent, id, altName, mainName)
	local b = CreateFrame("Button", nil, parent);
	b:SetSize(TdkpAltsFrame:GetWidth() - 10, Const.DKPTableRowHeight);
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	b:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
	b:GetNormalTexture():SetAlpha(0.5)
	b:GetNormalTexture():SetAllPoints(true)

	b.Alt = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.Alt:SetFontObject("GameFontHighlight")
	b.Alt:SetText(altName);
	b.Alt:SetPoint(Const.LEFT_POINT, Const.Margin, 0)
	b.Alt.originalValue = altName;

	b:RegisterForClicks("AnyUp");
	b:SetScript("OnClick", function (self, button, down)
		if button == "LeftButton" then
			if not IsShiftKeyDown() then
				selectedAlts = {}
			end
			local altSelected = DAL:Table_Search(selectedAlts, altName);
			if altSelected == false then
				table.insert(selectedAlts, altName);
			else
				table.remove(selectedAlts, playerSelected);
			end
			UpdateAltListRowsTextures();
		end
	end);

	View:AttachHoverOverTooltip(b, mainName, nil);
	
	return b
end


local function PopulateAltList(parentFrame, alts)
	parentFrame.scrollChild.Rows = {}

	for i = 1, #alts do
		local mainName = DAL:GetMainName(alts[i]);
		parentFrame.scrollChild.Rows[i] = CreateAltListRow(parentFrame.scrollChild, i, alts[i], mainName);
		if i == 1 then
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild, Const.TOP_LEFT_POINT, 0, -2)
		else
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild.Rows[i - 1], Const.BOTTOM_LEFT_POINT)
		end
	end
end


local function CreateAltList()
    local alts = DAL:GetAlts();

    TdkpAltsFrame.altList = CreateFrame("ScrollFrame", 'AltScrollFrame', TdkpAltsFrame, "UIPanelScrollFrameTemplate");
    local altList = TdkpAltsFrame.altList
	altList:SetFrameStrata("HIGH");
	altList:SetFrameLevel(9);

	altList:SetSize( 130, 150 );
	altList:SetPoint( Const.TOP_LEFT_POINT, 10, -30 );
	altList.scrollBar = _G["AltScrollFrameScrollBar"]; --fuckin xml -> lua glue magic

    altList.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", altList );
	altList.scrollChild:SetHeight( Const.DKPTableRowHeight*(#alts)+3 );
    altList.scrollChild:SetWidth( 130 );
	altList.scrollChild:SetAllPoints( altList );
	altList.scrollChild.bg = altList.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	altList.scrollChild.bg:SetAllPoints(true)
	altList.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	altList:SetScrollChild( altList.scrollChild );

	PopulateAltList(altList, alts);
end


function View:CreateAltsFrame(parentFrame)
	TdkpAltsFrame = View:CreateContainerFrame("ThirtyDKP_AltFrame", parentFrame, ALT_FRAME_TITLE, 170, 250);

    TdkpAltsFrame.removeAltBtn = CreateFrame("Button", nil, TdkpAltsFrame, "GameMenuButtonTemplate");
    TdkpAltsFrame.removeAltBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, TdkpAltsFrame, Const.BOTTOM_RIGHT_POINT, -10, 10);
    TdkpAltsFrame.removeAltBtn:SetSize(110, Const.ButtonHeight);
    TdkpAltsFrame.removeAltBtn:SetText("Remove");
    TdkpAltsFrame.removeAltBtn:SetNormalFontObject("GameFontNormal");
    TdkpAltsFrame.removeAltBtn:SetHighlightFontObject("GameFontHighlight");
    TdkpAltsFrame.removeAltBtn:RegisterForClicks("AnyUp");
	TdkpAltsFrame.removeAltBtn:SetScript("OnClick", function (self, button, down)
        if #selectedAlts < 1 then
            Core:Print("Please select alts to remove from the alt list")
            return;
        end
		DAL:RemoveAlts(selectedAlts);
        View:UpdateAltsFrame()
    end);

	TdkpAltsFrame.addAltBtn = CreateFrame("Button", nil, TdkpAltsFrame, "GameMenuButtonTemplate");
    TdkpAltsFrame.addAltBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, TdkpAltsFrame.removeAltBtn, Const.TOP_RIGHT_POINT, 0, 0);
    TdkpAltsFrame.addAltBtn:SetSize(110, Const.ButtonHeight);
    TdkpAltsFrame.addAltBtn:SetText("Add");
    TdkpAltsFrame.addAltBtn:SetNormalFontObject("GameFontNormal");
    TdkpAltsFrame.addAltBtn:SetHighlightFontObject("GameFontHighlight");
    TdkpAltsFrame.addAltBtn:RegisterForClicks("AnyUp");
	TdkpAltsFrame.addAltBtn:SetScript("OnClick", function (self, button, down)
		local selectedPlayers = View:GetSelectedDKPTableEntries();
		if #selectedPlayers < 1 then
			Core:Print("You must select a main first");
		elseif #selectedPlayers > 1 then
			Core:Print("You cannot have more than one main selected");
		else
			OpenNewAltFrame(selectedPlayers[1]);
		end
    end);

	TdkpAltsFrame.testBtn = CreateFrame("Button", nil, TdkpAltsFrame, "GameMenuButtonTemplate");
    TdkpAltsFrame.testBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, TdkpAltsFrame.addAltBtn, Const.TOP_RIGHT_POINT, 0, 0);
    TdkpAltsFrame.testBtn:SetSize(110, Const.ButtonHeight);
    TdkpAltsFrame.testBtn:SetText("Test Adjust");
    TdkpAltsFrame.testBtn:SetNormalFontObject("GameFontNormal");
    TdkpAltsFrame.testBtn:SetHighlightFontObject("GameFontHighlight");
    TdkpAltsFrame.testBtn:RegisterForClicks("AnyUp");
	TdkpAltsFrame.testBtn:SetScript("OnClick", function (self, button, down)
		Core:AdjustPlayersDKP(selectedAlts, 10, "TEST");
    end);

	CreateAltList();

	CreateNewAltFrame(TdkpAltsFrame);
end


function View:UpdateAltsFrame()
	local tdkpMainFrame = View:GetMainFrame()

	TdkpAltsFrame:Hide()
	TdkpAltsFrame:SetParent(nil)
	TdkpAltsFrame = nil;

	View:CreateAltsFrame(tdkpMainFrame)
	TdkpAltsFrame:Show()
end


function View:ToggleAltsFrame()
    TdkpAltsFrame:SetShown(not TdkpAltsFrame:IsShown());
end


function View:HideAltsFrame()
    TdkpAltsFrame:SetShown(false);
end
