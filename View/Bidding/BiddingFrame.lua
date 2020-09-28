local addonName, ThirtyDKP = ...
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local DAL = ThirtyDKP.DAL;
local Const = ThirtyDKP.View.Constants;

local BiddingFrame = nil;

function View:CreateBiddingFrame(item)
    if BiddingFrame then
        BiddingFrame:Hide()
        BiddingFrame:SetParent(nil)
        BiddingFrame = nil;
    end

    local _,_,_,_,_,_,_,_,_,itemIcon = GetItemInfo(item)
    local biddingFramePosition = DAL:GetBiddingFramePosition()

	BiddingFrame = CreateFrame('Frame', 'ThirtyDKP_BiddingFrame', UIParent, "TooltipBorderedFrameTemplate"); 
	BiddingFrame:Hide()
	BiddingFrame:SetSize(Const.LootTableWidth+50, 60);
    BiddingFrame:SetFrameStrata("DIALOG");
    BiddingFrame:SetClampedToScreen(true);
    BiddingFrame:SetFrameLevel(10);
	BiddingFrame:SetPoint(biddingFramePosition.point, UIParent, biddingFramePosition.relativePoint, biddingFramePosition.x, biddingFramePosition.y); -- point, relative frame, relative point on relative frame
    BiddingFrame:EnableMouse(true);
    BiddingFrame:SetMovable(true);
	BiddingFrame:RegisterForDrag("LeftButton");
	BiddingFrame:SetScript("OnDragStart", BiddingFrame.StartMoving);
    BiddingFrame:SetScript("OnDragStop", function()
        BiddingFrame:StopMovingOrSizing();
        local point, _, relativePoint, xOfs, yOfs = BiddingFrame:GetPoint();
        DAL:SetBiddingFramePosition(point, relativePoint, xOfs, yOfs)
    end
    );

    BiddingFrame.itemIconTexture = BiddingFrame:CreateTexture(nil, Const.OVERLAY_LAYER, nil);
    BiddingFrame.itemIconTexture:SetPoint(Const.TOP_LEFT_POINT, 5 ,-5)
    BiddingFrame.itemIconTexture:SetColorTexture(0, 0, 0, 1)
    BiddingFrame.itemIconTexture:SetSize(28, 28);
    BiddingFrame.itemIconTexture:SetTexture(itemIcon)

    BiddingFrame.ItemIconButton = CreateFrame("Button", "ThirtyDKPBiddingFrameIconButton", BiddingFrame)
    BiddingFrame.ItemIconButton:SetPoint(Const.TOP_LEFT_POINT, BiddingFrame.itemIconTexture, Const.TOP_LEFT_POINT, 0, 0);
    BiddingFrame.ItemIconButton:SetSize(28, 28);

    ActionButton_ShowOverlayGlow(BiddingFrame.ItemIconButton)

	BiddingFrame.itemName = BiddingFrame:CreateFontString(nil, Const.OVERLAY_LAYER);
	BiddingFrame.itemName:SetFontObject("GameFontHighlight");
    BiddingFrame.itemName:SetPoint(Const.LEFT_POINT, BiddingFrame.itemIconTexture, Const.RIGHT_POINT, 10, 0);
    BiddingFrame.itemName:SetText(item);

    BiddingFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 15, 0);
        GameTooltip:SetHyperlink(item);
    end)

    BiddingFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    

    -- Buttons

    BiddingFrame.closeBtn = CreateFrame("Button", nil, BiddingFrame, "UIPanelCloseButton")
	BiddingFrame.closeBtn:SetPoint(Const.TOP_RIGHT_POINT, BiddingFrame, Const.TOP_RIGHT_POINT)
    tinsert(UISpecialFrames, BiddingFrame:GetName()); -- Sets frame to close on "Escape"

    BiddingFrame.BiddingBtn = CreateFrame("Button", nil, BiddingFrame, "GameMenuButtonTemplate");
    BiddingFrame.BiddingBtn:SetPoint(Const.BOTTOM_LEFT_POINT, BiddingFrame, Const.BOTTOM_LEFT_POINT, 5, 5);
    BiddingFrame.BiddingBtn:SetSize(90, 22);
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
    BiddingFrame.PassBtn:SetSize(90, 22);
    BiddingFrame.PassBtn:SetText("Pass");
    BiddingFrame.PassBtn:SetNormalFontObject("GameFontNormal");
    BiddingFrame.PassBtn:SetHighlightFontObject("GameFontHighlight");
    BiddingFrame.PassBtn:RegisterForClicks("AnyUp");
    BiddingFrame.PassBtn:SetScript("OnClick", function(self, button)
        Core:SubmitBidPass()
        BiddingFrame:Hide()
    end)

    BiddingFrame.RollBtn = CreateFrame("Button", nil, BiddingFrame, "GameMenuButtonTemplate");
    BiddingFrame.RollBtn:SetPoint(Const.LEFT_POINT, BiddingFrame.PassBtn, Const.RIGHT_POINT, 0, 0);
    BiddingFrame.RollBtn:SetSize(90, 22);
    BiddingFrame.RollBtn:SetText("Roll");
    BiddingFrame.RollBtn:SetNormalFontObject("GameFontNormal");
    BiddingFrame.RollBtn:SetHighlightFontObject("GameFontHighlight");
    BiddingFrame.RollBtn:RegisterForClicks("AnyUp");
    BiddingFrame.RollBtn:SetScript("OnClick", function(self, button)
        RandomRoll(1, 100);
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
