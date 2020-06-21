local addonName, ThirtyDKP = ... 

local DAL = ThirtyDKP.DAL

local function SortTable()
	table.sort(ThirtyDKP_Database_CurrentLoot, function(a, b)
        return a["timestamp"] < b["timestamp"]
    end)
end


function DAL:InitializeCurrentLootTable()
    -- saved variables starts as nil. we want a empty tables
    if not ThirtyDKP_Database_CurrentLoot then ThirtyDKP_Database_CurrentLoot = {} end;

	SortTable()
end

function DAL:GetCurrentLootTable()
    SortTable()

	return ThirtyDKP_Database_CurrentLoot
end