local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View

local isUpToDate = false
local recievedUpdates = 0

local latestKnownDKPTableVersion = nil
local latestKnownHistoryVersion = nil

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


local function CompareDataVersions()
    local dataGuildname, _, dataVersionDate = strsplit("-", DAL:GetDKPTableVersion())
    local _, _, historyVersionDate = strsplit("-", DAL:GetDKPHistoryVersion())
    local dataStatusText = ""

    if tonumber(dataVersionDate) > 0 then
        local currentGuildName = GetGuildInfo("player");
        local _, _, latestKnownDKPTableDate = string.split("-", latestKnownDKPTableVersion)
        local _, _, latestKnownHistoryDate = string.split("-", latestKnownHistoryVersion)

        if not currentGuildName == dataGuildname then
            Core:Print("Actual guild: "..currentGuildName.." mismatches with ThirtyDKP data guild name: "..dataGuildname..".")
            dataStatusText = "Actual guild: "..currentGuildName.." mismatches with ThirtyDKP data guild name: "..dataGuildname.."."
        
        elseif recievedUpdates < 4 then
            Core:Print("Not enough updates recieved. Try again when more guildies are online.")
            dataStatusText = "Not enough updates recieved. Try again when more guildies are online."

        elseif tonumber(latestKnownDKPTableDate) <= tonumber(dataVersionDate) and tonumber(latestKnownHistoryDate) <= tonumber(historyVersionDate) then
            isUpToDate = true
            Core:Print("Data up-to-date.");

        elseif not isUpToDate then
            local formattedDate = Core:FormatTimestamp(latestKnownDKPTableDate)
            Core:Print("Newer DKP data found from "..formattedDate..". By "..knownLatestVersionOwner..".");
            dataStatusText = "Newer DKP data found from "..formattedDate..". By "..knownLatestVersionOwner.."."
        end
    else
        -- No history or version to check, so probably brand new install.
        Core:Print("No ThirtyDKP data found. If new installation, go raiding or request broadcast from admins.")
    end
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

function Core:GetGuildName()
    local currentGuildName = GetGuildInfo("player");
    if currentGuildName == nil then
        C_Timer.After(2, function() 
            currentGuildName = GetGuildInfo("player");
            return currentGuildName
        end)
    else
        return currentGuildName
    end
end

