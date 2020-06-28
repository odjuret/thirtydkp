local addonName, ThirtyDKP = ... 

local DAL = ThirtyDKP.DAL

function DAL:InitializeDKPHistory()
    -- saved variables starts as nil. we want a empty tables
    if not ThirtyDKP_Database_DKPHistory then ThirtyDKP_Database_DKPHistory = {} end;
end

function DAL:AddToHistory(affectedPlayers, amount, reason)
    if(type(amount) == "string") then
        -- todo: percentage 
    else
        local currentTime = time();
        local index = UnitName("player").."-"..currentTime
        tinsert(ThirtyDKP_Database_DKPHistory, {
            players=affectedPlayers,
            dkp=amount,
            timestamp=currentTime,
            index=index,
            reason=reason
        });
    end
end
