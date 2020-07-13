local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL

local isUpToDate = false

function Core:CheckDataVersion()
    local history = DAL:GetDKPHistory();

    if #history > 0 and history.version then
        local latestHistoryEntry = history[#history];

        local entrySender, entryDate = strsplit("-", latestHistoryEntry.index) 
        local versionSender, versionDate = strsplit("-", history.version) 

        if tonumber(entryDate) <= tonumber(versionDate) then
            isUpToDate = true
        end

        if isUpToDate then
            Core:Print("ThirtyDKP data is up do date.")
        else
            Core:Print("ThirtyDKP data is out of date, request an update from "..entrySender)
        end

    else
        -- No history or version to check, so probably brand new install.
        Core:Print("No ThirtyDKP data found. If new installation, go raiding or request broadcast from admins.")
    end
end
