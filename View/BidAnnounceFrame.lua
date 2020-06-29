local addonName, ThirtyDKP = ...
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local DAL = ThirtyDKP.DAL;
local Const = ThirtyDKP.View.Constants;

local BidAnnounceFrame = nil;
local IncomingBidsFrame = nil;

local selectedItem = nil;
local selectedBidder = nil;
-- todo: move this logic outside the view folder
local incomingBids = {};


local function UpdateIncomingBidsRowsTextures()
    for i,row in ipairs(IncomingBidsFrame.scrollChild.Rows) do 
        if selectedBidder and row.bidder.player == selectedBidder.bidder.player then
            row:SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
            row:GetNormalTexture():SetAlpha(1)
        else
            row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
            row:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
            row:GetNormalTexture():SetAlpha(0.2)
        end
    end
end

local function CreateIncomingBidsTableRow(parent, id, incomingBidsTable)

	local b = CreateFrame("Button", nil, parent);
	b:SetSize(parent:GetWidth(), Const.DKPTableRowHeight);
	b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
	b:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
	b:GetNormalTexture():SetAlpha(0.5)
	b:GetNormalTexture():SetAllPoints(true)

	b.DKPInfo = {}
	b.DKPInfo.PlayerName = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.PlayerName:SetFontObject("GameFontHighlight")
	b.DKPInfo.PlayerName:SetText(tostring(incomingBidsTable[id].player));
	b.DKPInfo.PlayerName:SetPoint(Const.LEFT_POINT, 30, 0)

	b.DKPInfo.CurrentDKP = b:CreateFontString(nil, Const.OVERLAY_LAYER)
	b.DKPInfo.CurrentDKP:SetFontObject("GameFontHighlight")
	b.DKPInfo.CurrentDKP:SetText(tostring(incomingBidsTable[id].dkp));
    b.DKPInfo.CurrentDKP:SetPoint(Const.RIGHT_POINT, -30, 0)

    b.bidder = incomingBidsTable[id]
    
    b:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            selectedBidder = self
            UpdateIncomingBidsRowsTextures()
        end
    end)

	return b
end

local function PopulateIncomingBidsTable(parentFrame, numberOfRows)
	parentFrame.scrollChild.Rows = {}

	for i = 1, numberOfRows do
		parentFrame.scrollChild.Rows[i] = CreateIncomingBidsTableRow(parentFrame.scrollChild, i, incomingBids)
		if i==1 then
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild, Const.TOP_LEFT_POINT, 0, -2)
		else
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild.Rows[i-1], Const.BOTTOM_LEFT_POINT)
		end
	end
end

local function CreateIncomingBidsFrame()
    local numberOfIncomingBids = #incomingBids

    -- "Container" frame that clips out its child frame "excess" content.
    IncomingBidsFrame = CreateFrame("ScrollFrame", 'IncomingBidsFrameScrollFrame', BidAnnounceFrame.CurrentItemForBidFrame, "UIPanelScrollFrameTemplate");

    IncomingBidsFrame:SetSize( Const.LootTableWidth-12, Const.DKPTableRowHeight*8);
	IncomingBidsFrame:SetPoint( Const.TOP_LEFT_POINT, BidAnnounceFrame.CurrentItemForBidFrame, Const.TOP_LEFT_POINT, 0, -30 );
	--IncomingBidsFrame:SetPoint( Const.BOTTOM_RIGHT_POINT, BidAnnounceFrame.CurrentItemForBidFrame, Const.BOTTOM_RIGHT_POINT, -22, 40 );
	IncomingBidsFrame.scrollBar = _G["IncomingBidsFrameScrollFrameScrollBar"]; --fuckin xml -> lua glue magic

	-- Child frame which holds all the content being scrolled through.
    IncomingBidsFrame.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", IncomingBidsFrame );
	if numberOfIncomingBids > 8 then
        IncomingBidsFrame.scrollChild:SetHeight( Const.DKPTableRowHeight*numberOfIncomingBids+2 );
    else
        IncomingBidsFrame.scrollChild:SetHeight( IncomingBidsFrame:GetHeight() );
    end
    IncomingBidsFrame.scrollChild:SetWidth( IncomingBidsFrame:GetWidth() );
	IncomingBidsFrame.scrollChild:SetAllPoints( IncomingBidsFrame );
	IncomingBidsFrame.scrollChild.bg = IncomingBidsFrame.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	IncomingBidsFrame.scrollChild.bg:SetAllPoints(true)
	IncomingBidsFrame.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

    IncomingBidsFrame:SetScrollChild( IncomingBidsFrame.scrollChild );

    PopulateIncomingBidsTable(IncomingBidsFrame, numberOfIncomingBids)
end


local function CreateCurrentItemForBidFrame()
    BidAnnounceFrame.CurrentItemForBidFrame = CreateFrame('Frame', nil, BidAnnounceFrame, nil);
    local f = BidAnnounceFrame.CurrentItemForBidFrame;
    local itemName, itemIcon = "", nil

    f:SetSize( Const.LootTableWidth+10, BidAnnounceFrame:GetHeight()/2);
	f:SetPoint( Const.TOP_LEFT_POINT, BidAnnounceFrame, Const.TOP_LEFT_POINT, 5, -15 );

    f.itemIcon = f:CreateTexture(nil, Const.OVERLAY_LAYER, nil);
    f.itemIcon:SetPoint(Const.TOP_LEFT_POINT, 5, 5)
    f.itemIcon:SetColorTexture(0, 0, 0, 1)
    f.itemIcon:SetSize(28, 28);

	f.itemName = f:CreateFontString(nil, Const.OVERLAY_LAYER);
	f.itemName:SetFontObject("GameFontHighlight");
    f.itemName:SetPoint(Const.LEFT_POINT, f.itemIcon, Const.RIGHT_POINT, 10, 0);

    if selectedItem then
        itemName,_,_,_,_,_,_,_,_,itemIcon = GetItemInfo(selectedItem.item.loot)
        if itemIcon then
            f.itemIcon:SetTexture(itemIcon)
            f.itemName:SetText(selectedItem.item.loot);
        end
    else
        f.itemName:SetText("Select an item to auction...");
    end

    f.AwardItemBtn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate");
    f.AwardItemBtn:SetPoint(Const.BOTTOM_RIGHT_POINT, f, Const.BOTTOM_RIGHT_POINT, 0, 0);
    f.AwardItemBtn:SetSize(100, 22);
    f.AwardItemBtn:SetText("Award Item");
    f.AwardItemBtn:SetNormalFontObject("GameFontNormal");
    f.AwardItemBtn:SetHighlightFontObject("GameFontHighlight");
    f.AwardItemBtn:RegisterForClicks("AnyUp");
    f.AwardItemBtn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if selectedBidder ~= nil then
                Core:AwardItem(selectedBidder.bidder, selectedItem.item.loot);
                selectedBidder = nil
                View:UpdateIncomingBidsFrame();
            else
                Core:Print("You need to select a bidder to award an item.")
            end
        end
    end)

    if not IncomingBidsFrame then
        CreateIncomingBidsFrame()
    else
        View:UpdateIncomingBidsFrame()
    end
end

function View:UpdateIncomingBidsFrame()
    IncomingBidsFrame:Hide()
	IncomingBidsFrame:SetParent(nil)
	IncomingBidsFrame = nil;

	CreateIncomingBidsFrame()
    IncomingBidsFrame:Show()
    UpdateIncomingBidsRowsTextures()
end

function View:AddBidder(bidder)
    local alreadyExists = DAL:Table_Search(incomingBids, bidder.player, 'player')
    if alreadyExists == false then
        table.insert(incomingBids, bidder);
        View:UpdateIncomingBidsFrame()
    else
        Core:Print("Tell the fucknut "..bidder.player.." to stop spamming!")
    end
end


----------------------
-- Loot table frames 
----------------------
local function UpdateLootTableRowsTextures()
    for i,row in ipairs(BidAnnounceFrame.LootTable.scrollChild.Rows) do 
        if selectedItem and row.item.index == selectedItem.item.index then
            row:SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
            row:GetNormalTexture():SetAlpha(1)
        else
            row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
            row:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
            row:GetNormalTexture():SetAlpha(0.2)
        end
    end
end

local function CreateLootTableRow(parent, id, lootTable)
	local row = CreateFrame("Button", nil, parent);
    row:SetSize(Const.LootTableWidth, Const.LootTableRowHeight);

    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
    row:SetNormalTexture("Interface\\COMMON\\talent-blue-glow")
    row:GetNormalTexture():SetAlpha(0.2)


	row.itemLink = row:CreateFontString(nil, Const.OVERLAY_LAYER)
	row.itemLink:SetFontObject("GameFontHighlight")
	row.itemLink:SetText(lootTable[id].loot);
    row.itemLink:SetPoint(Const.LEFT_POINT, 10, 0)

    row.item = lootTable[id]
    
    row:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 15, 0);
        GameTooltip:SetHyperlink(lootTable[id].loot);
    end)

    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    row:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            selectedItem = self
            UpdateLootTableRowsTextures()
            View:UpdateItemForBidFrame()
        end
    end)

	return row
end

local function PopulateLootTable(parentFrame, numberOfRows)
	local lootTableCopy = DAL:GetCurrentLootTable()
	parentFrame.scrollChild.Rows = {}

	for i = 1, numberOfRows do
		parentFrame.scrollChild.Rows[i] = CreateLootTableRow(parentFrame.scrollChild, i, lootTableCopy)
		if i==1 then
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild, Const.TOP_LEFT_POINT, 0, -2)
		else
			parentFrame.scrollChild.Rows[i]:SetPoint(Const.TOP_LEFT_POINT, parentFrame.scrollChild.Rows[i-1], Const.BOTTOM_LEFT_POINT)
		end
	end
end


local function CreateLootTableFrame()
    local numberOfRowsInLootTable = #DAL:GetCurrentLootTable()

    -- "Container" frame that clips out its child frame "excess" content.
    BidAnnounceFrame.LootTable = CreateFrame("ScrollFrame", 'BidAnnounceFrameScrollFrame', BidAnnounceFrame, "UIPanelScrollFrameTemplate");
    local lootTable = BidAnnounceFrame.LootTable

	lootTable:SetSize( Const.LootTableWidth, numberOfRowsInLootTable*7);
	lootTable:SetPoint( Const.TOP_LEFT_POINT, BidAnnounceFrame, Const.TOP_LEFT_POINT, 5, -Const.LootTableWidth );
	lootTable:SetPoint( Const.BOTTOM_RIGHT_POINT, BidAnnounceFrame, Const.BOTTOM_RIGHT_POINT, -27, 5 );
	lootTable.scrollBar = _G["BidAnnounceFrameScrollFrameScrollBar"]; --fuckin xml -> lua glue magic

	-- Child frame which holds all the content being scrolled through.
    lootTable.scrollChild = CreateFrame( "Frame", "$parent_ScrollChild", lootTable );
	lootTable.scrollChild:SetHeight( Const.LootTableRowHeight*numberOfRowsInLootTable+2 );
    lootTable.scrollChild:SetWidth( lootTable:GetWidth() );
	lootTable.scrollChild:SetAllPoints( lootTable );
	lootTable.scrollChild.bg = lootTable.scrollChild:CreateTexture(nil, Const.BACKGROUND_LAYER)
	lootTable.scrollChild.bg:SetAllPoints(true)
	lootTable.scrollChild.bg:SetColorTexture(0, 0, 0, 1)

	lootTable:SetScrollChild( lootTable.scrollChild );

	PopulateLootTable(lootTable, numberOfRowsInLootTable);
end

-----------------------------
-- Bid announce frame and functions
-----------------------------
function View:CreateBidAnnounceFrame()
	BidAnnounceFrame = CreateFrame('Frame', 'ThirtyDKP_BidAnnounceFrame', UIParent, "TooltipBorderedFrameTemplate"); 
	BidAnnounceFrame:SetShown(false);
	BidAnnounceFrame:SetSize(Const.LootTableWidth+20, 400);
    BidAnnounceFrame:SetFrameStrata("HIGH");
    BidAnnounceFrame:SetFrameLevel(10);

    -- todo: attach to blizz LootFrame as a button maybe?
	BidAnnounceFrame:SetPoint(Const.CENTER_POINT, UIParent, Const.CENTER_POINT, -200, 0); -- point, relative frame, relative point on relative frame
    BidAnnounceFrame:EnableMouse(true);
    BidAnnounceFrame:SetMovable(true);
	BidAnnounceFrame:RegisterForDrag("LeftButton");
	BidAnnounceFrame:SetScript("OnDragStart", BidAnnounceFrame.StartMoving);
    BidAnnounceFrame:SetScript("OnDragStop", BidAnnounceFrame.StopMovingOrSizing);

    BidAnnounceFrame.closeBtn = CreateFrame("Button", nil, BidAnnounceFrame, "UIPanelCloseButton")
	BidAnnounceFrame.closeBtn:SetPoint(Const.TOP_RIGHT_POINT, BidAnnounceFrame, Const.TOP_RIGHT_POINT)
    tinsert(UISpecialFrames, BidAnnounceFrame:GetName()); -- Sets frame to close on "Escape"
    
    
    -- Buttons
    -- Todo: input frame so user can choose bid timer

    BidAnnounceFrame.StartAndStopBiddingBtn = CreateFrame("Button", nil, BidAnnounceFrame, "GameMenuButtonTemplate");
    BidAnnounceFrame.StartAndStopBiddingBtn:SetPoint(Const.TOP_RIGHT_POINT, BidAnnounceFrame, Const.TOP_RIGHT_POINT, -5, -220);
    BidAnnounceFrame.StartAndStopBiddingBtn:SetSize(100, 22);
    BidAnnounceFrame.StartAndStopBiddingBtn:SetText("Start Bidding");
    BidAnnounceFrame.StartAndStopBiddingBtn:SetNormalFontObject("GameFontNormal");
    BidAnnounceFrame.StartAndStopBiddingBtn:SetHighlightFontObject("GameFontHighlight");
    BidAnnounceFrame.StartAndStopBiddingBtn:RegisterForClicks("AnyUp");
    BidAnnounceFrame.StartAndStopBiddingBtn:SetScript("OnClick", function(self, button)
        if selectedItem then
            if not Core:IsBiddingInProgress() then
                Core:StartBidding(selectedItem.item.loot, 15)
            else
                Core:Print("An item is already out for bid, please wait.")
            end
        else
            Core:Print("Please select an item to start bidding for.")
        end
        
    end)

    CreateLootTableFrame()
    CreateCurrentItemForBidFrame()
end

function View:ToggleBidAnnounceFrame()
    if not BidAnnounceFrame then
        View:CreateBidAnnounceFrame()
    else
        View:UpdateLootTableFrame();
    end
    
    BidAnnounceFrame:SetShown(not BidAnnounceFrame:IsShown());
end

function View:HideBidAnnounceFrame()
    BidAnnounceFrame:SetShown(false);
end

function View:UpdateItemForBidFrame()
	BidAnnounceFrame.CurrentItemForBidFrame:Hide()
	BidAnnounceFrame.CurrentItemForBidFrame:SetParent(nil)
	BidAnnounceFrame.CurrentItemForBidFrame = nil;

	CreateCurrentItemForBidFrame()
	BidAnnounceFrame.CurrentItemForBidFrame:Show()
end

function View:UpdateLootTableFrame()
	BidAnnounceFrame.LootTable:Hide()
	BidAnnounceFrame.LootTable:SetParent(nil)
	BidAnnounceFrame.LootTable = nil;

	CreateLootTableFrame()
	BidAnnounceFrame.LootTable:Show()
end