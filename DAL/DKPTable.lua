local addonName, ThirtyDKP = ... 

local DAL = ThirtyDKP.DAL

local function SortTable()
	local sortMode = DAL:GetDKPTableSorting().mode
	local sortColumn = DAL:GetDKPTableSorting().column

	if sortMode == "Ascending" then
		table.sort(ThirtyDKP_Database_DKPTable, function(a, b)
			return a[sortColumn] < b[sortColumn]
		end)
	else
		table.sort(ThirtyDKP_Database_DKPTable, function(a, b)
			return a[sortColumn] > b[sortColumn]
		end)
	end
end


function DAL:InitializeDKPTable()
    -- saved variables starts as nil. we want a empty tables
    if not ThirtyDKP_Database_DKPTable then ThirtyDKP_Database_DKPTable = {} end;

	SortTable()
end

function DAL:GetDKPTable()
    SortTable()
	
    return ThirtyDKP_Database_DKPTable;
end

function DAL:GetNumberOfRowsInDKPTable()
	
    return #ThirtyDKP_Database_DKPTable;
end

function DAL:WipeAndSetNewDKPTable(newTable)
	ThirtyDKP_Database_DKPTable = {}
	ThirtyDKP_Database_DKPTable = newTable

end

-- todo: move table search out of this file
-- returns index if found
-- else false
function DAL:Table_Search(tar, val, field)
	local value = string.upper(tostring(val));
	local location = {}
	for k,v in pairs(tar) do
		if(type(v) == "table") then
			local temp1 = k
			for k,v in pairs(v) do
				if(type(v) == "table") then
					local temp2 = k;
					for k,v in pairs(v) do
						if(type(v) == "table") then
							local temp3 = k
							for k,v in pairs(v) do
								if string.upper(tostring(v)) == value then
									if field then
										if k == field then
											tinsert(location, {temp1, temp2, temp3, k} )
										end
									else
										tinsert(location, {temp1, temp2, temp3, k} )
									end
								end;
							end
						end
						if string.upper(tostring(v)) == value then
							if field then
								if k == field then
									tinsert(location, {temp1, temp2, k} )
								end
							else
								tinsert(location, {temp1, temp2, k} )
							end
						end;
					end
				end
				if string.upper(tostring(v)) == value then
					if field then
						if k == field then
							tinsert(location, {temp1, k} )
						end
					else
						tinsert(location, {temp1, k} )
					end
				end;
			end
		end
		if string.upper(tostring(v)) == value then
			if field then
				if k == field then
					tinsert(location, k)
				end
			else
				tinsert(location, k)
			end
		end;
	end
	if (#location > 0) then
		return location;
	else
		return false;
	end
end

function DAL:GetFromDKPTable(playerName)
	local playerExists = DAL:Table_Search(ThirtyDKP_Database_DKPTable, playerName, 'player')

	if playerExists == false then
		return false 
	else
		return ThirtyDKP_Database_DKPTable[playerExists[1][1]]
	end
end

-- returns true if successfully adds player to dkp table
-- returns false if player already exists in dkp table
function DAL:AddToDKPTable(playerName, playerClass)
    local playerExists = DAL:Table_Search(ThirtyDKP_Database_DKPTable, playerName, 'player')
  
    if playerExists == false then
        tinsert(ThirtyDKP_Database_DKPTable, {
            player=playerName,
            class=playerClass,
            dkp=0,
        });

        return true;
    else
        return false;
    end
    
end

function DAL:RemoveFromDKPTable()
end

function DAL:AdjustPlayerDKP(playerName, adjustment)
	local playerExists = DAL:Table_Search(ThirtyDKP_Database_DKPTable, playerName, 'player')

	if playerExists == false then
        return false;
	else
		local currentDKP = ThirtyDKP_Database_DKPTable[playerExists[1][1]].dkp
		ThirtyDKP_Database_DKPTable[playerExists[1][1]].dkp = currentDKP + adjustment 
        return true;
    end
end

function DAL:UpdateDKPTableVersion()
	local currentTime = time();
	local index = UnitName("player").."-"..currentTime
	ThirtyDKP_Database_DKPTable.version = index
end

function DAL:GetDKPTableVersion()
	return ThirtyDKP_Database_DKPTable.version
end
