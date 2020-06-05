local addonName, ThirtyDKP = ...

-- Initializing the view
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;


local function CreateDKPTableRow(parent, id)
	local b = CreateFrame("Button", nil, parent);
	b:SetSize(Const.DKPTableWidth-100, Const.DKPTableRowHeight);
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square");
	b:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
	b:GetNormalTexture():SetAlpha(0.5)
	b:GetNormalTexture():SetAllPoints(true)

	b.DKPInfo = {}
	b.DKPInfo.PlayerName = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.PlayerName:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerName:SetText(tostring(ThirtyDKP.DAL.DKPTableCopy[id].player));
	b.DKPInfo.PlayerName:SetPoint(Const.LEFT_POINT, 30, 0)

	b.DKPInfo.PlayerClass = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.PlayerClass:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerClass:SetText(tostring(ThirtyDKP.DAL.DKPTableCopy[id].class));
	b.DKPInfo.PlayerClass:SetPoint(Const.CENTER_POINT)

	b.DKPInfo.CurrentDKP = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.CurrentDKP:SetFontObject("GameFontHighlight")
	b.DKPInfo.CurrentDKP:SetText(tostring(ThirtyDKP.DAL.DKPTableCopy[id].dkp));
	b.DKPInfo.CurrentDKP:SetPoint(Const.RIGHT_POINT, -80, 0)
	return b
end


local function PopulateDKPTable(parentFrame)
	parentFrame.scrollChild.Rows = {}
	for i = 1, ThirtyDKP.DAL.DKPTableNumRows do
		parentFrame.scrollChild.Rows[i] = CreateDKPTableRow(parentFrame.scrollChild, i)
		if i==1 then
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild, Const.TOP_LEFT_POINT, 0, -2)
		else
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild.Rows[i-1], Const.BOTTOMLEFT_POINT)
		end
	end
end


function View:CreateDKPTable(parentFrame)
	-- "Container" frame that clips out its child frame "excess" content.
	parentFrame.DKPTable = CreateFrame("ScrollFrame", 'DKPTableScrollFrame', parentFrame, "UIPanelScrollFrameTemplate");
	local scrollFrame = parentFrame.DKPTable
	scrollFrame:SetSize( Const.DKPTableWidth, ThirtyDKP.DAL.DKPTableNumRows*12);
	scrollFrame.scrollBar = _G["DKPTableScrollFrameScrollBar"]; --fuckin xml -> lua glue magic
	scrollFrame:SetPoint( Const.TOP_LEFT_POINT, 10, -30 );
	scrollFrame:SetPoint( Const.BOTTOMRIGHT_POINT, -120, 10 );

	-- Child frame which holds all the content being scrolled through.
    parentFrame.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", scrollFrame );
	parentFrame.scrollChild:SetHeight( Const.DKPTableRowHeight*ThirtyDKP.DAL.DKPTableNumRows+3 );
    parentFrame.scrollChild:SetWidth( scrollFrame:GetWidth() );
	parentFrame.scrollChild:SetAllPoints( scrollFrame );
	parentFrame.scrollChild.bg = parentFrame.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	parentFrame.scrollChild.bg:SetAllPoints(true)
	parentFrame.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	scrollFrame:SetScrollChild( parentFrame.scrollChild );

	PopulateDKPTable(parentFrame)
end

function View:UpdateDKPTable()
    --todo clean and repopulate dkptable frame
end