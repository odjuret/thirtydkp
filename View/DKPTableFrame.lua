local addonName, ThirtyDKP = ...

-- Initializing the view
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local DAL = ThirtyDKP.DAL;
local Const = ThirtyDKP.View.Constants;

local DKPTableFrame = nil;

local function CreateDKPTableRow(parent, id, dkpTable)

	local b = CreateFrame("Button", nil, parent);
	b:SetSize(Const.DKPTableWidth-100, Const.DKPTableRowHeight);
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	b:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
	b:GetNormalTexture():SetAlpha(0.5)
	b:GetNormalTexture():SetAllPoints(true)

	b.DKPInfo = {}
	b.DKPInfo.PlayerName = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.PlayerName:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerName:SetText(tostring(dkpTable[id].player));
	b.DKPInfo.PlayerName:SetPoint(Const.LEFT_POINT, 30, 0)

	b.DKPInfo.PlayerClass = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.PlayerClass:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerClass:SetText(tostring(dkpTable[id].class));
	b.DKPInfo.PlayerClass:SetPoint(Const.CENTER_POINT)

	b.DKPInfo.CurrentDKP = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.CurrentDKP:SetFontObject("GameFontHighlight")
	b.DKPInfo.CurrentDKP:SetText(tostring(dkpTable[id].dkp));
	b.DKPInfo.CurrentDKP:SetPoint(Const.RIGHT_POINT, -80, 0)
	return b
end


local function PopulateDKPTable(parentFrame, numberOfRows)
	local dkpTableCopy = DAL:GetDKPTable()
	parentFrame.scrollChild.Rows = {}

	for i = 1, numberOfRows do
		parentFrame.scrollChild.Rows[i] = CreateDKPTableRow(parentFrame.scrollChild, i, dkpTableCopy)
		if i==1 then
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild, Const.TOP_LEFT_POINT, 0, -2)
		else
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild.Rows[i-1], Const.BOTTOMLEFT_POINT)
		end
	end
end


function View:CreateDKPTable(parentFrame)
	local numberOfRowsInDKPTable = DAL:GetNumberOfRowsInDKPTable()
	-- "Container" frame that clips out its child frame "excess" content.
	DKPTableFrame = CreateFrame("ScrollFrame", 'DKPTableScrollFrame', parentFrame, "UIPanelScrollFrameTemplate");
	DKPTableFrame:SetFrameStrata("HIGH");
	DKPTableFrame:SetFrameLevel(9);

	DKPTableFrame:SetSize( Const.DKPTableWidth, numberOfRowsInDKPTable*12);
	DKPTableFrame.scrollBar = _G["DKPTableScrollFrameScrollBar"]; --fuckin xml -> lua glue magic
	DKPTableFrame:SetPoint( Const.TOP_LEFT_POINT, 10, -30 );
	DKPTableFrame:SetPoint( Const.BOTTOMRIGHT_POINT, -120, 10 );

	-- Child frame which holds all the content being scrolled through.
    DKPTableFrame.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", DKPTableFrame );
	DKPTableFrame.scrollChild:SetHeight( Const.DKPTableRowHeight*numberOfRowsInDKPTable+3 );
    DKPTableFrame.scrollChild:SetWidth( DKPTableFrame:GetWidth() );
	DKPTableFrame.scrollChild:SetAllPoints( DKPTableFrame );
	DKPTableFrame.scrollChild.bg = DKPTableFrame.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	DKPTableFrame.scrollChild.bg:SetAllPoints(true)
	DKPTableFrame.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	DKPTableFrame:SetScrollChild( DKPTableFrame.scrollChild );

	PopulateDKPTable(DKPTableFrame, numberOfRowsInDKPTable);
end

function View:UpdateDKPTable()
	Core:Print("Attempting to update table")
	local mainFrame = View:GetMainFrame()

	DKPTableFrame:Hide()
	DKPTableFrame:SetParent(nil)
	DKPTableFrame = nil;

	View:CreateDKPTable(mainFrame)
	DKPTableFrame:Show()
end