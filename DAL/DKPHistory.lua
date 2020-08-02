local addonName, ThirtyDKP = ... 

local DAL = ThirtyDKP.DAL

function DAL:InitializeDKPHistory()
    -- saved variables starts as nil. we want a empty tables
    if not ThirtyDKP_Database_DKPHistory then ThirtyDKP_Database_DKPHistory = {} end;
end

function DAL:GetDKPHistory()
    return ThirtyDKP_Database_DKPHistory
end

function DAL:GetLatestDKPHistoryEntry()
    return ThirtyDKP_Database_DKPHistory[#ThirtyDKP_Database_DKPHistory]
end

function DAL:AddToHistory(affectedPlayers, amount, reason)
    if(type(amount) == "string") then
        -- todo: percentage 
    else
        local currentTime = time();
        local index = UnitName("player").."-"..currentTime
        if not index == ThirtyDKP_Database_DKPHistory[#ThirtyDKP_Database_DKPHistory].index and not reason == ThirtyDKP_Database_DKPHistory[#ThirtyDKP_Database_DKPHistory].reason then
            tinsert(ThirtyDKP_Database_DKPHistory, {
                players=affectedPlayers,
                dkp=amount,
                timestamp=currentTime,
                index=index,
                reason=reason
            });
        end
    end
end

function DAL:DeleteHistoryEntry(entry)
    if #ThirtyDKP_Database_DKPHistory > 0 then
        local entryExists = DAL:Table_Search(ThirtyDKP_Database_DKPHistory, entry.index, 'index')
        local results = nil;

        if entryExists == false then
            return false 
        end
        
        -- Entries can have same index
        for i, matchingEntry in ipairs(entryExists) do
            print(ThirtyDKP_Database_DKPHistory[matchingEntry[1]].reason)
            -- todo finish
            
            
        end
    end
end


function DAL:WipeAndSetNewHistory(newHistory)
    ThirtyDKP_Database_DKPHistory = {}
    ThirtyDKP_Database_DKPHistory = newHistory
end

function DAL:UpdateDKPHistoryVersion()
	local currentTime = time();
	local index = UnitName("player").."-"..currentTime
	ThirtyDKP_Database_DKPHistory.version = index
end