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

    -- prune old loot entries (older than 7 days)
    if #ThirtyDKP_Database_CurrentLoot > 0 then
        local aWeekAgoTimestamp = (time() - (7*24*60*60));
        local entriesToRemove = {}

        for i, lootEntry in ipairs(ThirtyDKP_Database_CurrentLoot) do 
            if lootEntry.timestamp < aWeekAgoTimestamp then
                table.insert(entriesToRemove, i)
            end
        end
    
        for i, lootEntry in ipairs(entriesToRemove) do 
            table.remove(ThirtyDKP_Database_CurrentLoot, i)
        end
    end

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
