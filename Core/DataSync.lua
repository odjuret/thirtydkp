local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View

local isUpToDate = false
local recievedUpdates = 0

local latestKnownDKPTableVersion = nil
local latestKnownHistoryVersion = nil

--[[
    To attempt to ascertain if local data is up to date we collect data table versions (i.e. ThirtyDKP_Database_DKPTable.version)
    from online guild members to validate and compare against. Since we can not communicate with offline guild members (to collect their versions), 
    we can never fully trust local data.
]]--

function Core:GetLatestKnownVersionOwner()
    if latestKnownDKPTableVersion == nil then
        return "Unknown"
    else
        local _, latestKnownVersionOwner, _ = strsplit("-", latestKnownDKPTableVersion)
        return latestKnownVersionOwner
    end
end

function Core:IsDataUpToDate()
    return isUpToDate
end

function Core:CheckHistoryDataVersion(incomingHistoryDataVersion)
    local localHistoryVersion = DAL:GetDKPHistoryVersion()
    if not incomingHistoryDataVersion == localHistoryVersion then
        isUpToDate = false
        
        View:UpdateDataUpToDateFrame("Your local data is outdated.")
        return isUpToDate
    else
        return true
    end
end

local function InitializeLatestKnownVersions()
    DAL:InitializeDKPTableVersion();
    DAL:InitializeHistoryVersion();

    latestKnownDKPTableVersion = DAL:GetDKPTableVersion()
    latestKnownHistoryVersion = DAL:GetDKPHistoryVersion()
end

function Core:GetLatestKnownVersions()
    if latestKnownDKPTableVersion == nil or latestKnownHistoryVersion == nil then
        InitializeLatestKnownVersions()
    end
    return latestKnownDKPTableVersion, latestKnownHistoryVersion
end


local function TryUpdateKnownDKPTableVersion(incomingDKPTableVersion)
    local _, _, latestKnownDate = string.split("-", latestKnownDKPTableVersion)
    local _, _, incomingDate = string.split("-", incomingDKPTableVersion)

    if (incomingDate > latestKnownDate) then
        latestKnownDKPTableVersion = incomingDKPTableVersion
    end
end

local function TryUpdateKnownHistoryVersion(incomingHistoryVersion)
    local _, _, latestKnownDate = string.split("-", latestKnownHistoryVersion)
    local _, _, incomingDate = string.split("-", incomingHistoryVersion)

    if (incomingDate > latestKnownDate) then
        latestKnownDKPTableVersion = incomingHistoryVersion
    end
end

function Core:TryUpdateKnownVersions(incomingVersionsMessage)
    if latestKnownDKPTableVersion == nil or latestKnownHistoryVersion == nil then
        InitializeLatestKnownVersions()
    end
    local incomingDKPTableVersion, incomingHistoryVersion = string.split("/", incomingVersionsMessage)

    if not Core:DoesDataBelongToSameGuild(incomingDKPTableVersion, incomingHistoryVersion) then
        return;
    end

    TryUpdateKnownDKPTableVersion(incomingDKPTableVersion)
    TryUpdateKnownHistoryVersion(incomingHistoryVersion)

    recievedUpdates = recievedUpdates +1
end

-- todo compare options version if admin
local function CompareDataVersions()
    local dataGuildname, _, dataVersionDate = strsplit("-", DAL:GetDKPTableVersion())
    local _, _, historyVersionDate = strsplit("-", DAL:GetDKPHistoryVersion())
    local dataStatusText = ""

    if tonumber(dataVersionDate) > 0 then
        local currentGuildName = GetGuildInfo("player");
        local _, _, latestKnownDKPTableDate = string.split("-", latestKnownDKPTableVersion)
        local _, _, latestKnownHistoryDate = string.split("-", latestKnownHistoryVersion)

        if not currentGuildName == dataGuildname then
            dataStatusText = "Actual guild: "..currentGuildName.." mismatches with ThirtyDKP data guild name: "..dataGuildname.."."
        
        elseif recievedUpdates < 4 then
            dataStatusText = "Not enough updates recieved. Try again when more guildies are online."

        elseif (tonumber(latestKnownDKPTableDate) > tonumber(dataVersionDate)) then
            local formattedDate = Core:FormatTimestamp(latestKnownDKPTableDate)
            dataStatusText = "Newer DKP data found from "..formattedDate..". By "..knownLatestVersionOwner.."."

        else 
            -- Could not find any newer data versions
            if latestKnownDKPTableVersion ~= latestKnownHistoryVersion then
                dataStatusText = "Your local data is outdated."
            else
                isUpToDate = true
                dataStatusText = "Data up-to-date."
            end
        end
    else
        -- No history or version to check, so probably brand new install.
        dataStatusText = "No ThirtyDKP data found. If new installation, go raiding or request broadcast from admins."
    end

    Core:Print(dataStatusText)
    View:UpdateDataUpToDateFrame(dataStatusText)
end

function Core:CheckDataVersion()
    C_Timer.After(1, function() 
        local currentGuildName = GetGuildInfo("player");
        if currentGuildName == nil then
            Core:Print("No guild to sync data with.")
        else
            Core:Print("Attempting to sync DKP data with online guildies.")
            -- Request data versions from online members

            local dkpTableVersion, historyVersion = Core:GetLatestKnownVersions();
            Core:RequestDataVersionSync(dkpTableVersion.."/"..historyVersion)

            C_Timer.After(6, CompareDataVersions)
        end
    end)
end

function Core:DoesDataBelongToSameGuild(incomingDKPTableDataVersion, incomingHistoryDataVersion)
    local results = false
    local incomingGuildname = strsplit("-", incomingDKPTableDataVersion)
    local guildname = strsplit("-", DAL:GetDKPTableVersion()) 

    if guildname == incomingGuildname then
        results = true
    end
    if incomingHistoryDataVersion ~= nil then
        local incomingHistoryGuildname = strsplit("-", incomingHistoryDataVersion)
        if not guildname == incomingHistoryGuildname then
            results = false
        end
    end
    
    return results
end

