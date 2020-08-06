local addonName, ThirtyDKP = ... 

local DAL = ThirtyDKP.DAL
local Core = ThirtyDKP.Core;

function DAL:InitializeDKPHistory()
    -- saved variables starts as nil. we want a empty tables
    if not ThirtyDKP_Database_DKPHistory then ThirtyDKP_Database_DKPHistory = {} end;
end

function DAL:InitializeHistoryVersion()
	if not ThirtyDKP_Database_DKPHistory.version then
		local guildName = GetGuildInfo("player");
		local historyDataVersion = guildName.."-"..UnitName("player").."-"..0;
		ThirtyDKP_Database_DKPHistory.version = historyDataVersion
	end
end

function DAL:GetDKPHistory()
    return ThirtyDKP_Database_DKPHistory
end

function DAL:GetLatestDKPHistoryEntry()
    return ThirtyDKP_Database_DKPHistory[#ThirtyDKP_Database_DKPHistory]
end

function DAL:AddEntryToHistory(newHistoryEntry)
    if #ThirtyDKP_Database_DKPHistory > 0 then
        if not (newHistoryEntry.index == ThirtyDKP_Database_DKPHistory[#ThirtyDKP_Database_DKPHistory].index and newHistoryEntry.reason == ThirtyDKP_Database_DKPHistory[#ThirtyDKP_Database_DKPHistory].reason) then
            tinsert(ThirtyDKP_Database_DKPHistory, newHistoryEntry);
        end
    else
        tinsert(ThirtyDKP_Database_DKPHistory, newHistoryEntry);
    end
end


function DAL:AddToHistory(affectedPlayers, amount, reason)
    local currentTime = time();
    local index = UnitName("player").."-"..currentTime
    local newHistoryEntry = {
        players=affectedPlayers,
        dkp=amount,
        timestamp=currentTime,
        index=index,
        reason=reason
    }
    if #ThirtyDKP_Database_DKPHistory > 0 then
        if not (index == ThirtyDKP_Database_DKPHistory[#ThirtyDKP_Database_DKPHistory].index and reason == ThirtyDKP_Database_DKPHistory[#ThirtyDKP_Database_DKPHistory].reason) then
            tinsert(ThirtyDKP_Database_DKPHistory, newHistoryEntry);
        end
    else
        tinsert(ThirtyDKP_Database_DKPHistory, newHistoryEntry);
    end
    return newHistoryEntry;
end

function DAL:DeleteHistoryEntry(entry)
    if #ThirtyDKP_Database_DKPHistory > 0 then
        local entryExists = DAL:Table_Search(ThirtyDKP_Database_DKPHistory, entry.index, 'index')
        local results = nil;

        if entryExists == false then
            return false 
        end
        
        -- Entries can have same index
        for _, matchingEntry in ipairs(entryExists) do
            if ThirtyDKP_Database_DKPHistory[matchingEntry[1]].reason == entry.reason then
                local removed = table.remove(ThirtyDKP_Database_DKPHistory, matchingEntry[1])
            end
        end
    end
end

function DAL:WipeAndSetNewHistory(newHistory)
    ThirtyDKP_Database_DKPHistory = {}
    ThirtyDKP_Database_DKPHistory = newHistory
end

function DAL:UpdateDKPHistoryVersion(newHistoryVersion)
    if (newHistoryVersion == nil or newHistoryVersion == "") then
        local currentTime = time();
	    local index = UnitName("player").."-"..currentTime
	    ThirtyDKP_Database_DKPHistory.version = index 
    else
        ThirtyDKP_Database_DKPHistory.version = newHistoryVersion
    end
end

function DAL:GetDKPHistoryVersion()
    return ThirtyDKP_Database_DKPHistory.version;
end
