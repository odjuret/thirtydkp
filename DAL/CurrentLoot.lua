local addonName, ThirtyDKP = ... 

local DAL = ThirtyDKP.DAL

local function SortTable()
	table.sort(ThirtyDKP_Database_CurrentLoot, function(a, b)
        return a["timestamp"] < b["timestamp"]
    end)
end

local function SearchCurrentLootTable(itemLink)
    for index, tableItemLink in ipairs(ThirtyDKP_Database_CurrentLoot) do
        if itemLink == tableItemLink.loot then
            return true
        end
    end

    return false
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

function DAL:AddToLootTable(itemLink)
    local alreadyInTable = SearchCurrentLootTable(itemLink);

    if not alreadyInTable then
        local curTime = time();
        local newIndex = UnitName("player").."-"..curTime
        tinsert(ThirtyDKP_Database_CurrentLoot, {
            loot=itemLink,
            index=newIndex,
            timestamp=curTime,
        });
    end
end
