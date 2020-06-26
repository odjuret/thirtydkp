local addonName, ThirtyDKP = ...
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;
local DAL = ThirtyDKP.DAL;
local Const = ThirtyDKP.View.Constants;


function View:CreateBiddingFrame(item)
    local itemName,_,_,_,_,_,_,_,_,itemIcon = GetItemInfo(item)

	BiddingFrame = CreateFrame('Frame', 'ThirtyDKP_BiddingFrame', UIParent, "ShadowOverlaySmallTemplate"); 
	BiddingFrame:SetShown(false);
	BiddingFrame:SetSize(200, 80);
    BiddingFrame:SetFrameStrata("HIGH");
    BiddingFrame:SetFrameLevel(10);
    BiddingFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
        tile = true, 
    });
    BiddingFrame:SetBackdropColor(0,0,0,0.8);
	BiddingFrame:SetPoint(Const.CENTER_POINT, UIParent, Const.CENTER_POINT, 200, 100); -- point, relative frame, relative point on relative frame
    BiddingFrame:EnableMouse(true);
    BiddingFrame:SetMovable(true);
	BiddingFrame:RegisterForDrag("LeftButton");
	BiddingFrame:SetScript("OnDragStart", BiddingFrame.StartMoving);
    BiddingFrame:SetScript("OnDragStop", BiddingFrame.StopMovingOrSizing);

    BiddingFrame.closeBtn = CreateFrame("Button", nil, BiddingFrame, "UIPanelCloseButton")
	BiddingFrame.closeBtn:SetPoint(Const.TOP_RIGHT_POINT, BiddingFrame, Const.TOP_RIGHT_POINT, 5, 5)
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
    BiddingFrame.BiddingBtn:SetPoint(Const.BOTTOMLEFT_POINT, BiddingFrame, Const.BOTTOMLEFT_POINT, 5, 5);
    BiddingFrame.BiddingBtn:SetSize(100, 22);
    BiddingFrame.BiddingBtn:SetText("Bid");
    BiddingFrame.BiddingBtn:SetNormalFontObject("GameFontNormal");
    BiddingFrame.BiddingBtn:SetHighlightFontObject("GameFontHighlight");
    BiddingFrame.BiddingBtn:RegisterForClicks("AnyUp");
    BiddingFrame.BiddingBtn:SetScript("OnClick", function(self, button)
        Core:SubmitBid()
    end)

    BiddingFrame:SetShown(true);
end

function View:ToggleBiddingFrame()
    BiddingFrame:SetShown(not BiddingFrame:IsShown());
end

function View:HideBiddingFrame()
    if BiddingFrame then
        BiddingFrame:SetShown(false);
    end 
end