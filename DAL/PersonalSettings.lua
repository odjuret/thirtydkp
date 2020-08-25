local addonName, ThirtyDKP = ...

local DAL = ThirtyDKP.DAL

function DAL:InitializePersonalSettings()
	if not ThirtyDKP_Database_PersonalSettings then
		ThirtyDKP_Database_PersonalSettings = {
			biddingFramePosition = { point="CENTER", relativePoint="CENTER", x=200, y=100 },
		}
	end
end


function DAL:GetBiddingFramePosition()
	return ThirtyDKP_Database_PersonalSettings.biddingFramePosition;
end


function DAL:SetBiddingFramePosition(point, relativePoint, xOfs, yOfs)
	ThirtyDKP_Database_PersonalSettings.biddingFramePosition.point = point;
	ThirtyDKP_Database_PersonalSettings.biddingFramePosition.relativePoint = relativePoint;
	ThirtyDKP_Database_PersonalSettings.biddingFramePosition.x = xOfs;
	ThirtyDKP_Database_PersonalSettings.biddingFramePosition.y = yOfs;
end