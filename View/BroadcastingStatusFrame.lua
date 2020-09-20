local addonName, ThirtyDKP = ...
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;

local BroadcastingStatusFrame = nil;

local bytesSent = 0
local bytesTotal = 0

local function CreateBroadcastingStatusFrame()
	local f = CreateFrame("Frame", "ThirtyDKP_BroadcastingStatusFrame", UIParent, "TooltipBorderedFrameTemplate");

	f:SetPoint("TOP", UIParent, "TOP", 0, -10);
	f:SetSize(210, 65);
	f:SetClampedToScreen(true)
	f:SetFrameStrata("DIALOG")
	f:SetFrameLevel(15)
	f:SetMovable(true);
	f:EnableMouse(true);
	f:RegisterForDrag("LeftButton");
	f:SetScript("OnDragStart", f.StartMoving);
	f:SetScript("OnDragStop", f.StopMovingOrSizing);
	f:Hide()

	f.bcastHeader = f:CreateFontString(nil, "OVERLAY")
	f.bcastHeader:SetFontObject("ThirtyDKPHeader");
	f.bcastHeader:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -15);
    f.bcastHeader:SetScale(0.8)
    f.bcastHeader:SetText("ThirtyDKP Data Broadcasting")

	f.status = CreateFrame("StatusBar", nil, f)
	f.status:SetSize(200, 15)
	f.status:SetBackdrop({
	    bgFile   = "Interface\\ChatFrame\\ChatFrameBackground", tile = true,
	  });
	f.status:SetBackdropColor(0, 0, 0, 0.7)
	f.status:SetStatusBarTexture([[Interface\TargetingFrame\UI-TargetingFrame-BarFill]])
	f.status:SetPoint("BOTTOM", f, "BOTTOM", 0, 25)

	f.status.percentage = f:CreateFontString(nil, "OVERLAY")
	f.status.percentage:SetFontObject("GameFontNormal");
	f.status.percentage:SetPoint("TOP", f.status, "BOTTOM", 0, -9);
	f.status.percentage:SetScale(0.6)

	return f
end

function View:ShowBroadcastingStatusFrame()
    if not BroadcastingStatusFrame then BroadcastingStatusFrame = CreateBroadcastingStatusFrame() end
    
	BroadcastingStatusFrame:Show()

	BroadcastingStatusFrame.status:Show()

	BroadcastingStatusFrame.status:SetMinMaxValues(0, 100)
	BroadcastingStatusFrame.status:SetStatusBarColor(0, 0.3, 1)
	BroadcastingStatusFrame.status:SetScript("OnUpdate", function(self)
		local val

		if bytesSent < bytesTotal then
			val = (bytesSent / bytesTotal) * 100
		else
			val = 100
		end

        self:SetValue(val)
        
		BroadcastingStatusFrame.status.percentage:SetText(Core:RoundNumber(val, 0).."%")

		if bytesSent == bytesTotal then
			self:SetValue(100)
			self:SetScript("OnUpdate", nil)
			C_Timer.After(2, function()
                BroadcastingStatusFrame:Hide()
                Core:RaidAnnounce("Broadcasting complete!")
			end)
		end
	end)
end

-------------------------------------------------
-- Callback used by communicator when transmitting 
-------------------------------------------------
function ThirtyDKP_BroadcastingCallback(arg1, arg2, arg3)
	bytesSent = arg2
    bytesTotal = arg3

	if arg2 == arg3 then
		bytesSent = 0
		bytesTotal = 0
	end
end