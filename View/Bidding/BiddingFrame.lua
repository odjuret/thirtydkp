local addonName, ThirtyDKP = ...
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local Const = ThirtyDKP.View.Constants;

local BiddingFrame = nil;

function View:CreateBiddingFrame(item)
    if BiddingFrame then
        BiddingFrame:Hide()
        BiddingFrame:SetParent(nil)
        BiddingFrame = nil;
    end

    local itemName,_,_,_,_,_,_,_,_,itemIcon = GetItemInfo(item)

	BiddingFrame = CreateFrame('Frame', 'ThirtyDKP_BiddingFrame', UIParent, "TooltipBorderedFrameTemplate"); 
	BiddingFrame:Hide()
	BiddingFrame:SetSize(Const.LootTableWidth, 60);
    BiddingFrame:SetFrameStrata("DIALOG");
    BiddingFrame:SetClampedToScreen(true);
    BiddingFrame:SetFrameLevel(10);
	BiddingFrame:SetPoint(Const.CENTER_POINT, UIParent, Const.CENTER_POINT, 200, 100); -- point, relative frame, relative point on relative frame
    BiddingFrame:EnableMouse(true);
    BiddingFrame:SetMovable(true);
	BiddingFrame:RegisterForDrag("LeftButton");
	BiddingFrame:SetScript("OnDragStart", BiddingFrame.StartMoving);
    BiddingFrame:SetScript("OnDragStop", BiddingFrame.StopMovingOrSizing);

    -- todo: standardize item frame and move into FrameFactory.lua 
    BiddingFrame.ItemFrame = CreateFrame('Frame', 'ThirtyDKP_BiddingFrame', BiddingFrame);
    local itemFrame = BiddingFrame.ItemFrame
    itemFrame:SetPoint(Const.TOP_LEFT_POINT, 5, -5)
    itemFrame:SetSize(Const.LootTableWidth-10, 28)

    itemFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 15, 0);
        GameTooltip:SetHyperlink(item);
    end)

    itemFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    itemFrame.itemIconTexture = itemFrame:CreateTexture(nil, Const.OVERLAY_LAYER, nil);
    itemFrame.itemIconTexture:SetPoint(Const.TOP_LEFT_POINT)
    itemFrame.itemIconTexture:SetColorTexture(0, 0, 0, 1)
    itemFrame.itemIconTexture:SetSize(28, 28);
    itemFrame.itemIconTexture:SetTexture(itemIcon)

    itemFrame.ItemIconButton = CreateFrame("Button", "ThirtyDKPBiddingFrameIconButton", itemFrame)
    itemFrame.ItemIconButton:SetPoint(Const.TOP_LEFT_POINT, itemFrame.itemIconTexture, Const.TOP_LEFT_POINT, 0, 0);
    itemFrame.ItemIconButton:SetSize(28, 28);

    ActionButton_ShowOverlayGlow(itemFrame.ItemIconButton)

	itemFrame.itemName = itemFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	itemFrame.itemName:SetFontObject("GameFontHighlight");
    itemFrame.itemName:SetPoint(Const.LEFT_POINT, itemFrame.itemIconTexture, Const.RIGHT_POINT, 10, 0);
    itemFrame.itemName:SetText(item);

    -- Buttons

    BiddingFrame.closeBtn = CreateFrame("Button", nil, BiddingFrame, "UIPanelCloseButton")
	BiddingFrame.closeBtn:SetPoint(Const.TOP_RIGHT_POINT, BiddingFrame, Const.TOP_RIGHT_POINT)
    tinsert(UISpecialFrames, BiddingFrame:GetName()); -- Sets frame to close on "Escape"

    BiddingFrame.BiddingBtn = CreateFrame("Button", nil, BiddingFrame, "GameMenuButtonTemplate");
    BiddingFrame.BiddingBtn:SetPoint(Const.BOTTOM_LEFT_POINT, BiddingFrame, Const.BOTTOM_LEFT_POINT, 5, 5);
    BiddingFrame.BiddingBtn:SetSize(100, 22);
    BiddingFrame.BiddingBtn:SetText("Bid");
    BiddingFrame.BiddingBtn:SetNormalFontObject("GameFontNormal");
    BiddingFrame.BiddingBtn:SetHighlightFontObject("GameFontHighlight");
    BiddingFrame.BiddingBtn:RegisterForClicks("AnyUp");
    BiddingFrame.BiddingBtn:SetScript("OnClick", function(self, button)
        Core:SubmitBid()
        BiddingFrame:Hide()
    end)

    BiddingFrame.PassBtn = CreateFrame("Button", nil, BiddingFrame, "GameMenuButtonTemplate");
    BiddingFrame.PassBtn:SetPoint(Const.LEFT_POINT, BiddingFrame.BiddingBtn, Const.RIGHT_POINT, 0, 0);
    BiddingFrame.PassBtn:SetSize(100, 22);
    BiddingFrame.PassBtn:SetText("Pass");
    BiddingFrame.PassBtn:SetNormalFontObject("GameFontNormal");
    BiddingFrame.PassBtn:SetHighlightFontObject("GameFontHighlight");
    BiddingFrame.PassBtn:RegisterForClicks("AnyUp");
    BiddingFrame.PassBtn:SetScript("OnClick", function(self, button)
        Core:SubmitBidPass()
        BiddingFrame:Hide()
    end)

    BiddingFrame:Show();
end

function View:ToggleBiddingFrame()
    BiddingFrame:SetShown(not BiddingFrame:IsShown());
end

function View:HideBiddingFrame()
    if BiddingFrame then
        BiddingFrame:Hide();
        BiddingFrame:SetParent(nil)
        BiddingFrame = nil;
    end
end
