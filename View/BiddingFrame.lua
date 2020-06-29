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
	BiddingFrame:SetSize(Const.LootTableWidth, 80);
    BiddingFrame:SetFrameStrata("DIALOG");
    BiddingFrame:SetClampedToScreen(true);
    BiddingFrame:SetFrameLevel(10);
	BiddingFrame:SetPoint(Const.CENTER_POINT, UIParent, Const.CENTER_POINT, 200, 100); -- point, relative frame, relative point on relative frame
    BiddingFrame:EnableMouse(true);
    BiddingFrame:SetMovable(true);
	BiddingFrame:RegisterForDrag("LeftButton");
	BiddingFrame:SetScript("OnDragStart", BiddingFrame.StartMoving);
    BiddingFrame:SetScript("OnDragStop", BiddingFrame.StopMovingOrSizing);

    BiddingFrame.closeBtn = CreateFrame("Button", nil, BiddingFrame, "UIPanelCloseButton")
	BiddingFrame.closeBtn:SetPoint(Const.TOP_RIGHT_POINT, BiddingFrame, Const.TOP_RIGHT_POINT)
    tinsert(UISpecialFrames, BiddingFrame:GetName()); -- Sets frame to close on "Escape"

    BiddingFrame.itemIconTexture = BiddingFrame:CreateTexture(nil, Const.OVERLAY_LAYER, nil);
    BiddingFrame.itemIconTexture:SetPoint(Const.TOP_LEFT_POINT, 5, -5)
    BiddingFrame.itemIconTexture:SetColorTexture(0, 0, 0, 1)
    BiddingFrame.itemIconTexture:SetSize(28, 28);
    BiddingFrame.itemIconTexture:SetTexture(itemIcon)

	BiddingFrame.itemName = BiddingFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	BiddingFrame.itemName:SetFontObject("GameFontHighlight");
    BiddingFrame.itemName:SetPoint(Const.LEFT_POINT, BiddingFrame.itemIconTexture, Const.RIGHT_POINT, 10, 0);
    BiddingFrame.itemName:SetText(item);

    -- Buttons
    -- Todo: input frame so user can choose bid timer

    BiddingFrame.BiddingBtn = CreateFrame("Button", nil, BiddingFrame, "GameMenuButtonTemplate");
    BiddingFrame.BiddingBtn:SetPoint(Const.BOTTOM_LEFT_POINT, BiddingFrame, Const.BOTTOM_LEFT_POINT, 5, 5);
    BiddingFrame.BiddingBtn:SetSize(100, 22);
    BiddingFrame.BiddingBtn:SetText("Bid");
    BiddingFrame.BiddingBtn:SetNormalFontObject("GameFontNormal");
    BiddingFrame.BiddingBtn:SetHighlightFontObject("GameFontHighlight");
    BiddingFrame.BiddingBtn:RegisterForClicks("AnyUp");
    BiddingFrame.BiddingBtn:SetScript("OnClick", function(self, button)
        Core:SubmitBid()
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
