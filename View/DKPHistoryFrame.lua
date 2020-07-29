local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local DKPHistoryFrame = nil;

local DKPHISTORY_FRAME_TITLE = "DKP History"


local function CreateDKPHistoryListRow(parent, id, dkpHistory, hasDateHeader)
	local b = CreateFrame("Button", nil, parent);
	b:SetSize(DKPHistoryFrame:GetWidth()-10, 45);
    
    -- reason
	b.reason = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.reason:SetFontObject("GameFontHighlight")
	b.reason:SetText(dkpHistory[id].reason);
    
    -- player string
	b.affectedPlayers = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.affectedPlayers:SetFontObject("GameFontHighlight")
	b.affectedPlayers:SetText(dkpHistory[id].players);
    
    if hasDateHeader then
        -- date header
        b.dateHeader = b:CreateFontString(nil, Const.OVERLAY_LAYER)
        b.dateHeader:SetFontObject("GameFontHighlight")
        b.dateHeader:SetText(dkpHistory[id].timestamp);

        b.dateHeader:SetPoint(Const.TOP_LEFT_POINT, b, Const.TOP_LEFT_POINT)   
        b.reason:SetPoint(Const.TOP_LEFT_POINT, b, Const.TOP_LEFT_POINT, 0, -10)
        b.affectedPlayers:SetPoint(Const.TOP_LEFT_POINT, b, Const.TOP_LEFT_POINT, 0, -20)
    else
        b.reason:SetPoint(Const.TOP_LEFT_POINT, b, Const.TOP_LEFT_POINT)
        b.affectedPlayers:SetPoint(Const.TOP_LEFT_POINT, b, Const.TOP_LEFT_POINT, 0, -10)
    end

	b:RegisterForClicks("AnyUp");
	b:SetScript("OnClick", function (self, button, down)
		if button == "RightButton" then
            -- todo: right click meny
		end
	end);
	
	return b
end


local function PopulateDKPHistoryList(scrollChild, dkpHistory)
    scrollChild.Rows = {}
    local lastEntryYear, lastEntryMonth, lastEntryDay, lastEntryTimeofday
    if #dkpHistory > 0 then
        lastEntryYear, lastEntryMonth, lastEntryDay, lastEntryTimeofday = Core:GetDateAndTimeArray(dkpHistory[#dkpHistory].timestamp);
    end

    for i = 0, #dkpHistory-1 do
        local entryYear, entryMonth, entryDay, entryTimeofday = Core:GetDateAndTimeArray(dkpHistory[#dkpHistory - i].timestamp);
        if i==0 or (entryYear ~= lastEntryYear and entryMonth ~= lastEntryMonth and entryDay ~= lastEntryDay) then
            scrollChild.Rows[i] = CreateDKPHistoryListRow(scrollChild, #dkpHistory - i, dkpHistory, true)
        else
            scrollChild.Rows[i] = CreateDKPHistoryListRow(scrollChild, #dkpHistory - i, dkpHistory, false)
        end
        
		if i==0 then
			scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, scrollChild, Const.TOP_LEFT_POINT, 0, -2)
		else
			scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, scrollChild.Rows[i-1], Const.BOTTOM_LEFT_POINT)
		end
	end
end

function View:CreateDKPHistoryFrame(parentFrame)
	DKPHistoryFrame = View:CreateContainerFrame(parentFrame, DKPHISTORY_FRAME_TITLE, 170, 190)

    local dkpHistory = DAL:GetDKPHistory()

    DKPHistoryFrame.HistoryScrollFrame = CreateFrame("ScrollFrame", 'DKPHistoryScrollFrame', DKPHistoryFrame, "UIPanelScrollFrameTemplate");
    local f = DKPHistoryFrame.HistoryScrollFrame;
	f:SetFrameStrata("HIGH");
	f:SetFrameLevel(9);

	f:SetSize( 130, 100 );
	f:SetPoint( Const.TOP_LEFT_POINT, 10, -30 );
	f.scrollBar = _G["DKPHistoryScrollFrameScrollBar"]; --fuckin xml -> lua glue magic

    f.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", f );
	f.scrollChild:SetHeight( (45*#dkpHistory)+3 );
    f.scrollChild:SetWidth( 130 );
	f.scrollChild:SetAllPoints( f );
	f.scrollChild.bg = f.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	f.scrollChild.bg:SetAllPoints(true)
	f.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	f:SetScrollChild( f.scrollChild );

	PopulateDKPHistoryList(f.scrollChild, dkpHistory);
end

function View:UpdateDKPHistoryFrame()
	local mainFrame = View:GetMainFrame()

	DKPHistoryFrame:Hide()
	DKPHistoryFrame:SetParent(nil)
	DKPHistoryFrame = nil;

	View:CreateDKPHistoryFrame(mainFrame)
	DKPHistoryFrame:Show()
end

function View:ToggleDKPHistoryFrame()
    DKPHistoryFrame:SetShown(not DKPHistoryFrame:IsShown());
end

function View:HideDKPHistoryFrame()
    DKPHistoryFrame:SetShown(false);
end