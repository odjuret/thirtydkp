local addonName, ThirtyDKP = ...

local DAL = ThirtyDKP.DAL
local Core = ThirtyDKP.Core;

function DAL:InitializeAltTable()
    -- saved variables starts as nil. we want a empty tables
    if not ThirtyDKP_Database_AltTable then ThirtyDKP_Database_AltTable = {} end;
end


function DAL:AddAlt(altName, mainName)
	if ThirtyDKP_Database_AltTable[altName] ~= nil then
		return false;
	else
		ThirtyDKP_Database_AltTable[altName] = mainName;
		return true;
	end
end


function DAL:RemoveAlts(altNames)
	for i, alt in ipairs(altNames) do
		ThirtyDKP_Database_AltTable[alt] = nil;
	end
end

function DAL:RemoveAllAltsForPlayers(playerNames)
	for i, playerName in ipairs(playerNames) do
		for alt, main in pairs(ThirtyDKP_Database_AltTable) do
			if main == playerName then
				ThirtyDKP_Database_AltTable[alt] = nil;
			end
		end
	end
end


function DAL:GetMainName(altName)
	return ThirtyDKP_Database_AltTable[altName];
end


function DAL:GetAlts()
	local alts = {};
	local i = 1;

	for alt, main in pairs(ThirtyDKP_Database_AltTable) do
		alts[i] = alt;
		i = i + 1;
	end

	table.sort(alts);
	return alts;
end
