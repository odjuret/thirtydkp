local addonName, ThirtyDKP = ...

-- Initializing the view
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local DAL = ThirtyDKP.DAL;
local Const = ThirtyDKP.View.Constants;

-- Even though its not a "standalone" frame by itself,
-- it deserves its own file since it will grow large as development progresses
local DKPTableFrame = nil;

local selectedDKPTableEntries = {};

function View:GetSelectedDKPTableEntries()
	return selectedDKPTableEntries;
end


local function UpdateDKPTableRowsTextures()
	for i, row in ipairs(DKPTableFrame.scrollChild.Rows) do 
		local playerIsSelected = DAL:Table_Search(selectedDKPTableEntries, row.DKPInfo.PlayerName.originalValue)
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


local function CreateDKPTableHeadersRow(parent)

	local headersFrame = CreateFrame("Frame", nil, parent);
	headersFrame:SetSize(Const.DKPTableWidth, Const.DKPTableRowHeight);

	headersFrame.playerHeaderBtn = CreateFrame("Button", nil, headersFrame);
    headersFrame.playerHeaderBtn:SetPoint(Const.LEFT_POINT)
    headersFrame.playerHeaderBtn:SetSize(headersFrame:GetWidth()/3, Const.DKPTableRowHeight);
    headersFrame.playerHeaderBtn:SetText("Name");
    headersFrame.playerHeaderBtn:SetNormalFontObject("GameFontNormal");
	headersFrame.playerHeaderBtn:SetHighlightFontObject("GameFontHighlight");
    headersFrame.playerHeaderBtn:GetFontString():SetPoint(Const.LEFT_POINT, Const.Margin, 0)
	headersFrame.playerHeaderBtn:RegisterForClicks("AnyUp");
	headersFrame.playerHeaderBtn:SetScript("OnClick", function ()
		DAL:ToggleDKPTableSorting("player")
		View:UpdateDKPTable()
	end);

	headersFrame.classHeaderBtn = CreateFrame("Button", nil, headersFrame);
    headersFrame.classHeaderBtn:SetPoint(Const.CENTER_POINT, Const.Margin, 0)
    headersFrame.classHeaderBtn:SetSize(headersFrame:GetWidth()/3, Const.DKPTableRowHeight);
    headersFrame.classHeaderBtn:SetText("Class");
    headersFrame.classHeaderBtn:SetNormalFontObject("GameFontNormal");
	headersFrame.classHeaderBtn:SetHighlightFontObject("GameFontHighlight");
	headersFrame.classHeaderBtn:RegisterForClicks("AnyUp");
	headersFrame.classHeaderBtn:SetScript("OnClick", function ()
		DAL:ToggleDKPTableSorting("class")
		View:UpdateDKPTable()
	end);

	headersFrame.dkpHeaderBtn = CreateFrame("Button", nil, headersFrame);
    headersFrame.dkpHeaderBtn:SetPoint(Const.RIGHT_POINT)
    headersFrame.dkpHeaderBtn:SetSize(headersFrame:GetWidth()/3, Const.DKPTableRowHeight);
    headersFrame.dkpHeaderBtn:SetText("DKP");
    headersFrame.dkpHeaderBtn:SetNormalFontObject("GameFontNormal");
	headersFrame.dkpHeaderBtn:SetHighlightFontObject("GameFontHighlight");
	headersFrame.dkpHeaderBtn:GetFontString():SetPoint(Const.RIGHT_POINT, -Const.Margin, 0)
	headersFrame.dkpHeaderBtn:RegisterForClicks("AnyUp");
	headersFrame.dkpHeaderBtn:SetScript("OnClick", function ()
		DAL:ToggleDKPTableSorting("dkp")
		View:UpdateDKPTable()
	end);

	return headersFrame
end

local function CreateDKPTableRow(parent, id, dkpTable)

	local b = CreateFrame("Button", nil, parent);
	b:SetSize(Const.DKPTableWidth, Const.DKPTableRowHeight);
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	b:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
	b:GetNormalTexture():SetAlpha(0.5)
	b:GetNormalTexture():SetAllPoints(true)

	b.DKPInfo = {}
	local originalPlayerNameValue = tostring(dkpTable[id].player);
	local colorizedName = Core:AddClassColor(originalPlayerNameValue, tostring(dkpTable[id].class))
	b.DKPInfo.PlayerName = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.PlayerName:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerName:SetText(colorizedName);
	b.DKPInfo.PlayerName:SetPoint(Const.LEFT_POINT, Const.Margin, 0)
	b.DKPInfo.PlayerName.originalValue = originalPlayerNameValue;

	local colorizedClass = Core:AddClassColor(tostring(dkpTable[id].class), tostring(dkpTable[id].class))
	b.DKPInfo.PlayerClass = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.PlayerClass:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerClass:SetText(colorizedClass);
	b.DKPInfo.PlayerClass:SetPoint(Const.CENTER_POINT, Const.Margin, 0);

	local colorizedDKP = Core:AddClassColor(tostring(dkpTable[id].dkp), tostring(dkpTable[id].class))
	b.DKPInfo.CurrentDKP = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.CurrentDKP:SetFontObject("GameFontHighlight")
	b.DKPInfo.CurrentDKP:SetText(colorizedDKP);
	b.DKPInfo.CurrentDKP:SetPoint(Const.RIGHT_POINT, -Const.Margin, 0)

	b:RegisterForClicks("AnyUp");
	b:SetScript("OnClick", function (self, button, down)
		if button == "LeftButton" then
			if not IsShiftKeyDown() then
				selectedDKPTableEntries = {}
			end
			local playerSelected = DAL:Table_Search(selectedDKPTableEntries, originalPlayerNameValue);
			if playerSelected == false then
				table.insert(selectedDKPTableEntries, originalPlayerNameValue);
			else
				table.remove(selectedDKPTableEntries, playerSelected[1]);
			end
			UpdateDKPTableRowsTextures();
		end
	end);
	
	return b
end


local function PopulateDKPTable(parentFrame, numberOfRows)
	local dkpTableCopy = DAL:GetDKPTable()
	parentFrame.scrollChild.Headers = CreateDKPTableHeadersRow(parentFrame.scrollChild)
	parentFrame.scrollChild.Headers:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild, Const.TOP_LEFT_POINT, 0, -2)
	parentFrame.scrollChild.Rows = {}

	for i = 1, numberOfRows do
		parentFrame.scrollChild.Rows[i] = CreateDKPTableRow(parentFrame.scrollChild, i, dkpTableCopy)
		if i==1 then
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild.Headers, Const.BOTTOM_LEFT_POINT)
		else
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild.Rows[i-1], Const.BOTTOM_LEFT_POINT)
		end
	end
end


function View:CreateDKPTable(parentFrame)
	local numberOfRowsInDKPTable = DAL:GetNumberOfRowsInDKPTable()
	-- "Container" frame that clips out its child frame "excess" content.
	DKPTableFrame = CreateFrame("ScrollFrame", 'DKPTableScrollFrame', parentFrame, "UIPanelScrollFrameTemplate");
	DKPTableFrame:SetFrameStrata("HIGH");
	DKPTableFrame:SetFrameLevel(9);

	DKPTableFrame:SetSize( Const.DKPTableWidth, Const.DKPTableRowHeight*12);
	DKPTableFrame:SetPoint( Const.TOP_LEFT_POINT, 5, -30 );
	DKPTableFrame.scrollBar = _G["DKPTableScrollFrameScrollBar"]; --fuckin xml -> lua glue magic

	-- Child frame which holds all the content being scrolled through.
    DKPTableFrame.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", DKPTableFrame );
	DKPTableFrame.scrollChild:SetHeight( Const.DKPTableRowHeight*(numberOfRowsInDKPTable+1)+3 );
    DKPTableFrame.scrollChild:SetWidth( Const.DKPTableWidth );
	DKPTableFrame.scrollChild:SetAllPoints( DKPTableFrame );
	DKPTableFrame.scrollChild.bg = DKPTableFrame.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	DKPTableFrame.scrollChild.bg:SetAllPoints(true)
	DKPTableFrame.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	DKPTableFrame:SetScrollChild( DKPTableFrame.scrollChild );

	PopulateDKPTable(DKPTableFrame, numberOfRowsInDKPTable);
end

function View:UpdateDKPTable()
	local mainFrame = View:GetMainFrame()

	DKPTableFrame:Hide()
	DKPTableFrame:SetParent(nil)
	DKPTableFrame = nil;

	View:CreateDKPTable(mainFrame)
	DKPTableFrame:Show()
end
