local addonName, ThirtyDKP = ... 

local DAL = ThirtyDKP.DAL

function DAL:InitializeDKPTable()
    ------------------------------------
    --	Import SavedVariables
    ------------------------------------
    -- saved variables starts as nil. we want a empty table
    if not ThirtyDKP_Database_DKPTable then ThirtyDKP_Database_DKPTable = {} end;
    DAL.DKPTableCopy 		= ThirtyDKP_Database_DKPTable;	
    DAL.DKPTableNumRows     = 0;
    if #ThirtyDKP_Database_DKPTable > 0 then DAL.DKPTableNumRows = #ThirtyDKP_Database_DKPTable end;

    table.sort(ThirtyDKP_Database_DKPTable, function(a, b)
        return a["player"] < b["player"]
    end)
    
end

function DAL:GetDKPTable()
    if not ThirtyDKP_Database_DKPTable then ThirtyDKP_Database_DKPTable = {} end;

    table.sort(ThirtyDKP_Database_DKPTable, function(a, b)
        return a["player"] < b["player"]
	end)
	
    return ThirtyDKP_Database_DKPTable;
end

function DAL:GetNumberOfRowsInDKPTable()
	if not ThirtyDKP_Database_DKPTable then ThirtyDKP_Database_DKPTable = {} end;
	
    return #ThirtyDKP_Database_DKPTable;
end

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

function DAL:AddToDKPTable(playerName, playerClass)

    --Will either contain index of player or false if not found
    local playerExists = DAL:Table_Search(ThirtyDKP_Database_DKPTable, playerName)
  
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


