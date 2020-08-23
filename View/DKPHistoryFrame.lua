local addonName, ThirtyDKP = ...
local DAL = ThirtyDKP.DAL;
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local DKPHistoryFrame = nil;

local DKPHISTORY_FRAME_TITLE = "DKP History"

local TDKP_DEFAULT_MAX_HISTORY_ROWS = 50;
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
	local totalEntryHeight = 32;

	-- entry header
	local colorizedDKPAdjust = "";
	local colorizedHeader = "";
	local maybeDecay, maybeDecayAmount = string.split(":", dkpHistory[id].reason)
	if maybeDecay == "Decay" then
		colorizedHeader = Core:ColorizeListHeader(maybeDecay)
		colorizedDKPAdjust = Core:ColorizeNegative(maybeDecayAmount.." DKP")
	else
		colorizedHeader = Core:ColorizeListHeader(dkpHistory[id].reason)
		colorizedDKPAdjust = Core:ColorizePositiveOrNegative(dkpHistory[id].dkp, tostring(dkpHistory[id].dkp).." DKP")
	end
	
	local madeBy = Core:TryToAddClassColor(string.split("-", dkpHistory[id].index))
	local headerText = colorizedDKPAdjust.." - "..colorizedHeader.." by "..madeBy
	b.entryHeader = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.entryHeader:SetFontObject("GameFontNormal")
	b.entryHeader:SetText(headerText);
	b.entryHeader:SetPoint(Const.TOP_LEFT_POINT, b, Const.TOP_LEFT_POINT, 15, 0)
    
	-- player string
	local colorizedPlayerString, rows = "", 0

	if not (maybeDecay == "Decay") then
		colorizedPlayerString, rows = Core:ColorizeAndBreakPlayers(dkpHistory[id].players);
	
		b.affectedPlayers = b:CreateFontString(nil, Const.OVERLAY_LAYER)
		b.affectedPlayers:SetFontObject("ThirtyDKPTinyLeft")
		b.affectedPlayers:SetText(colorizedPlayerString);
		b.affectedPlayers:SetPoint(Const.TOP_LEFT_POINT, b, Const.TOP_LEFT_POINT, 25, -15);
	else
		totalEntryHeight = 24;
	end

	for i = 1, rows do
		totalEntryHeight = totalEntryHeight + 8
	end
	
	b:SetSize(parent:GetWidth(), totalEntryHeight);
	dkpHistoryScrollChildHeight = dkpHistoryScrollChildHeight + totalEntryHeight;

	local sanitizedHeaderText = View:SanitizeTextForBlizzFunctions(headerText)

	b:RegisterForClicks("AnyDown");
	b:SetScript("OnClick", function (self, button, down)
		if button == "RightButton" then
			if Core:IsAddonAdmin() then
				View:CreateRightClickMenu(self, headerText, "Delete Entry", function() 
					StaticPopupDialogs["TDKP_REMOVE_HISTORY_ENTRY"] = {
						text = "Are you sure you want to delete\n "..sanitizedHeaderText.." \nand refund/remove affected players DKP?",
						button1 = "Yes",
						button2 = "No",
						OnAccept = function()
							Core:RevertHistory(dkpHistory[id]);
						end,
						timeout = 0,
						whileDead = true,
						hideOnEscape = true,
						preferredIndex = 3,
					};
					StaticPopup_Show ("TDKP_REMOVE_HISTORY_ENTRY", "", "")
				end)
			end
		end
	end);
	
	return b
end


local function PopulateDKPHistoryList(scrollChild, dkpHistory)
	scrollChild.Rows = {};
	if #dkpHistory > 0 then
		local totalScrollChildIndex = 0;
		local lastDate, lastTimeOfDay = strsplit(" ", Core:FormatTimestamp(dkpHistory[#dkpHistory].timestamp));
		for i = 0, (#dkpHistory-1) do
			if i > TDKP_DEFAULT_MAX_HISTORY_ROWS then
				return;
			end
			
			local entryDate, entryTimeOfDay = strsplit(" ", Core:FormatTimestamp(dkpHistory[(#dkpHistory-i)].timestamp));
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

			scrollChild.Rows[totalScrollChildIndex] = CreateDKPHistoryListEntry(scrollChild, (#dkpHistory - i), dkpHistory)
			
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
	DKPHistoryFrame = View:CreateContainerFrame("ThirtyDKP_HistoryFrame", parentFrame, DKPHISTORY_FRAME_TITLE, 432, 385)

	DKPHistoryFrame.helpText = DKPHistoryFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	DKPHistoryFrame.helpText:SetFontObject("ThirtyDKPTiny");
    DKPHistoryFrame.helpText:SetPoint(Const.TOP_LEFT_POINT, DKPHistoryFrame, Const.TOP_LEFT_POINT, 180, -20);
    DKPHistoryFrame.helpText:SetText(Core:ColorizeGrey("Right click to delete entry."))

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

	TDKP_DEFAULT_MAX_HISTORY_ROWS = 50;
 	dkpHistoryScrollChildHeight = 0;

	View:CreateDKPHistoryFrame(mainFrame)
end

function View:ToggleDKPHistoryFrame()
    DKPHistoryFrame:SetShown(not DKPHistoryFrame:IsShown());
end

function View:HideDKPHistoryFrame()
    DKPHistoryFrame:SetShown(false);
end