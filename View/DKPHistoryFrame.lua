local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local DKPHistoryFrame = nil;

local DKPHISTORY_FRAME_TITLE = "DKP History"

local DEFAULT_MAX_HISTORY_ROWS = 50;
local dkpHistoryScrollChildHeight = 0;


local function CreateDKPHistoryListDateHeader(parent, entryDate)
	local f = CreateFrame("Frame", nil, parent);
	f:SetSize(parent:GetWidth(), 20);
	dkpHistoryScrollChildHeight = dkpHistoryScrollChildHeight + 20;
	
	f.dateHeader = f:CreateFontString(nil, Const.OVERLAY_LAYER)
	f.dateHeader:SetFontObject("ThirtyDKPNormal")
	f.dateHeader:SetText(entryDate);
	f.dateHeader:SetPoint(Const.LEFT_POINT, 5, 0)
	return f
end

local function CreateDKPHistoryListEntry(parent, id, dkpHistory)
	local b = CreateFrame("Button", nil, parent);
    
	-- entry header
	local colorizedDKPAdjust = Core:ColorizePositiveOrNegative(dkpHistory[id].dkp, tostring(dkpHistory[id].dkp).." DKP")
	local colorizedHeader = Core:ColorizeListHeader(dkpHistory[id].reason)
	local madeBy = Core:TryToAddClassColor(string.split("-", dkpHistory[id].index))
	b.entryHeader = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.entryHeader:SetFontObject("ThirtyDKPNormal")
	b.entryHeader:SetText(colorizedDKPAdjust.." - "..colorizedHeader.." by "..madeBy);
	b.entryHeader:SetPoint(Const.TOP_LEFT_POINT, b, Const.TOP_LEFT_POINT, 15, 0)
    
	-- player string
	local colorizedPlayerString, rows = Core:ColorizeAndBreakPlayers(dkpHistory[id].players);

	b.affectedPlayers = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.affectedPlayers:SetFontObject("ThirtyDKPTinyLeft")
	b.affectedPlayers:SetText(colorizedPlayerString);
	b.affectedPlayers:SetPoint(Const.TOP_LEFT_POINT, b, Const.TOP_LEFT_POINT, 25, -15);

	local totalEntryHeight = 32;
	for i = 1, rows do
		totalEntryHeight = totalEntryHeight + 8
	end
	
	b:SetSize(parent:GetWidth(), totalEntryHeight);
	dkpHistoryScrollChildHeight = dkpHistoryScrollChildHeight + totalEntryHeight;

	b:RegisterForClicks("AnyUp");
	b:SetScript("OnClick", function (self, button, down)
		if button == "RightButton" then
            print("insert right click menu for "..tostring(id))
		end
	end);
	
	return b
end


local function PopulateDKPHistoryList(scrollChild, dkpHistory)
	scrollChild.Rows = {};
	if #dkpHistory > 0 then
		local totalScrollChildIndex = 0;
		local lastDate, lastTimeOfDay = strsplit(" ", Core:FormatTimestamp(dkpHistory[#dkpHistory].timestamp));
		for i, historyEntry in ipairs(dkpHistory) do 
			if i > DEFAULT_MAX_HISTORY_ROWS then
				return;
			end
			
			local entryDate, entryTimeOfDay = strsplit(" ", Core:FormatTimestamp(historyEntry.timestamp));
			if totalScrollChildIndex == 0 or (lastDate ~= entryDate) then
				-- insert and "attach" date header
				scrollChild.Rows[totalScrollChildIndex] = CreateDKPHistoryListDateHeader(scrollChild, entryDate)
				lastDate, lastTimeOfDay = entryDate, entryTimeOfDay;
				if totalScrollChildIndex == 0 then
					scrollChild.Rows[totalScrollChildIndex]:SetPoint(Const.TOP_LEFT_POINT, scrollChild, Const.TOP_LEFT_POINT, 0, -2)
				else
					scrollChild.Rows[totalScrollChildIndex]:SetPoint(Const.TOP_LEFT_POINT, scrollChild.Rows[totalScrollChildIndex-1], Const.BOTTOM_LEFT_POINT)
				end
				totalScrollChildIndex = totalScrollChildIndex + 1;
			end

			scrollChild.Rows[totalScrollChildIndex] = CreateDKPHistoryListEntry(scrollChild, (#dkpHistory + 1) - i, dkpHistory)
			
			if totalScrollChildIndex == 0 then
				scrollChild.Rows[totalScrollChildIndex]:SetPoint(Const.TOP_LEFT_POINT, scrollChild, Const.TOP_LEFT_POINT, 0, -2)
			else
				scrollChild.Rows[totalScrollChildIndex]:SetPoint(Const.TOP_LEFT_POINT, scrollChild.Rows[totalScrollChildIndex-1], Const.BOTTOM_LEFT_POINT)
			end
			totalScrollChildIndex = totalScrollChildIndex + 1;
		end
	end
end

function View:CreateDKPHistoryFrame(parentFrame)
	DKPHistoryFrame = View:CreateContainerFrame(parentFrame, DKPHISTORY_FRAME_TITLE, 432, 385)

    local dkpHistory = DAL:GetDKPHistory()

    DKPHistoryFrame.HistoryScrollFrame = CreateFrame("ScrollFrame", 'DKPHistoryScrollFrame', DKPHistoryFrame, "UIPanelScrollFrameTemplate");
    local f = DKPHistoryFrame.HistoryScrollFrame;
	f:SetFrameStrata("HIGH");
	f:SetFrameLevel(9);

	f:SetSize( 400, 350 );
	f:SetPoint( Const.TOP_LEFT_POINT, 5, -30 );
	f.scrollBar = _G["DKPHistoryScrollFrameScrollBar"]; --fuckin xml -> lua glue magic

    f.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", f );
    f.scrollChild:SetWidth( 400 );
	f.scrollChild.bg = f.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	f.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	f:SetScrollChild( f.scrollChild );

	PopulateDKPHistoryList(f.scrollChild, dkpHistory);

	f.scrollChild:SetHeight( dkpHistoryScrollChildHeight+3 );
	f.scrollChild:SetAllPoints( f );
	f.scrollChild.bg:SetAllPoints(true);
	
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