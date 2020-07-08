local addonName, ThirtyDKP = ...

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL

function Core:StartRaid()
	local raidInfo = DAL:GetRaid();
	raidInfo.raidOngoing = true;
end


function Core:EndRaid()
	local raidInfo = DAL:GetRaid();
	raidInfo.raidOngoing = false;
end


function Core:IsRaidStarted()
	return DAL:GetRaid().raidOngoing;
end
