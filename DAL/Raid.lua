local addonName, ThirtyDKP = ...

local DAL = ThirtyDKP.DAL

function DAL:InitializeRaid()
	if not ThirtyDKP_Database_Raid then
		ThirtyDKP_Database_Raid = {
			raidOngoing = false
		}
	end
end


function DAL:GetRaid()
	return ThirtyDKP_Database_Raid;
end
