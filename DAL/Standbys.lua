local addonName, ThirtyDKP = ...

local DAL = ThirtyDKP.DAL

function DAL:InitializeStandbys()
	if not ThirtyDKP_Database_Standbys then
		ThirtyDKP_Database_Standbys = {}
	end
end


function DAL:GetStandbys()
	return ThirtyDKP_Database_Standbys;
end

function DAL:AddStandby(playerName)
	local playerExists = DAL:Table_Search(ThirtyDKP_Database_Standbys, playerName)
  
    if playerExists == false then
        table.insert(ThirtyDKP_Database_Standbys, playerName);
    end
end

function DAL:RemoveStandby(playerName)
	local playerExists = DAL:Table_Search(ThirtyDKP_Database_Standbys, playerName)
    if playerExists ~= false then
        table.remove(ThirtyDKP_Database_Standbys, playerExists[1]);
    end
end