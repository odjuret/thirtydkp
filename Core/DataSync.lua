local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View

local isUpToDate = false
local recievedUpdates = 0
local knownLatestVersionGuild = nil
local knownLatestVersionOwner = nil
local knownLatestVersionDate = nil

function Core:GetLatestKnownVersionOwner()
    if knownLatestVersionOwner == nil then
        return "Unknown"
    else
        return knownLatestVersionOwner
    end
end


function Core:IsDataUpToDate()
    return isUpToDate
end

local function InitializeLatestKnownVersion()
    DAL:InitializeDKPTableVersion();
    local dkpTableVersion = DAL:GetDKPTableVersion()
    local localVersionGuild, localVersionOwner, localVersionDate = strsplit("-", dkpTableVersion)
    knownLatestVersionGuild = localVersionGuild
    knownLatestVersionOwner = localVersionOwner
    knownLatestVersionDate = localVersionDate
end

function Core:GetLatestKnownVersion()
    if knownLatestVersionOwner == nil or knownLatestVersionDate == nil or knownLatestVersionGuild == nil then
        InitializeLatestKnownVersion()
    end
    return knownLatestVersionGuild.."-"..knownLatestVersionOwner.."-"..knownLatestVersionDate
end

function Core:TryUpdateKnownVersion(incomingVersionIndex)
    local incomingGuildname, incomingVersionOwner, incomingVersionDate = strsplit("-", incomingVersionIndex)
    local guildname = strsplit("-", DAL:GetDKPTableVersion()) 
    if not incomingGuildname == guildname then
        return;
    end
    recievedUpdates = recievedUpdates +1

    if knownLatestVersionOwner == nil or knownLatestVersionDate == nil or knownLatestVersionGuild == nil then
        InitializeLatestKnownVersion()
    end

    if (incomingVersionDate > knownLatestVersionDate) then
        knownLatestVersionGuild = incomingGuildname
        knownLatestVersionOwner = incomingVersionOwner
        knownLatestVersionDate = incomingVersionDate
    end
end

local function CompareDataVersions()
    local dkpTableVersion = DAL:GetDKPTableVersion()
    local dataStatusText = ""

    if dkpTableVersion ~= nil then
        local dataGuildname, localVersionOwner, localVersionDate = strsplit("-", dkpTableVersion)
        local currentGuildName = GetGuildInfo("player");

        if not currentGuildName == dataGuildname then
            Core:Print("Actual guild: "..currentGuildName.." mismatches with ThirtyDKP data guild name: "..dataGuildname..".")
            dataStatusText = "Actual guild: "..currentGuildName.." mismatches with ThirtyDKP data guild name: "..dataGuildname.."."
        
        elseif recievedUpdates < 4 then
            Core:Print("Not enough updates recieved. Try again when more guildies are online.")
            dataStatusText = "Not enough updates recieved. Try again when more guildies are online."

        elseif tonumber(knownLatestVersionDate) <= tonumber(localVersionDate) then
            isUpToDate = true
            Core:Print("Data up-to-date.");

        elseif not isUpToDate then
            local formattedDate = Core:FormatTimestamp(knownLatestVersionDate)
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
            local latestKnownVersion = Core:GetLatestKnownVersion()
            Core:RequestDataVersionSync(latestKnownVersion)

            C_Timer.After(6, CompareDataVersions)
        end
    end)
end

function Core:DoesDataBelongToSameGuild(incomingDKPTableDataVersion)
    local results = false
    local incomingGuildname = strsplit("-", incomingDKPTableDataVersion)
    local guildname = strsplit("-", DAL:GetDKPTableVersion()) 

    if guildname == incomingGuildname then
        results = true
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

