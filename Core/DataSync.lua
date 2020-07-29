local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL

local isUpToDate = false
local knownLatestVersionOwner = nil
local knownLatestVersionDate = nil

local function InitializeLatestKnownVersion()
    local dkpTableVersion = DAL:GetDKPTableVersion()
    local localVersionOwner, localVersionDate = strsplit("-", dkpTableVersion)
    knownLatestVersionOwner = localVersionOwner
    knownLatestVersionDate = localVersionDate
end

function Core:GetLatestKnownVersion()
    if knownLatestVersionOwner == nil then
        InitializeLatestKnownVersion()
    end
    return knownLatestVersionOwner.."-"..knownLatestVersionDate
end


function Core:TryUpdateKnownVersion(incomingVersionIndex)
    local incomingVersionOwner, incomingVersionDate = strsplit("-", incomingVersionIndex)

    if knownLatestVersionOwner == nil then
        InitializeLatestKnownVersion()
    end

    if (incomingVersionDate > knownLatestVersionDate) then
        knownLatestVersionOwner = incomingVersionOwner
        knownLatestVersionDate = incomingVersionDate
    end
end

local function CompareDataVersions()
    local dkpTableVersion = DAL:GetDKPTableVersion()

    if dkpTableVersion ~= nil then
        local localVersionOwner, localVersionDate = strsplit("-", dkpTableVersion) 

        if tonumber(knownLatestVersionDate) <= tonumber(localVersionDate) then
            isUpToDate = true
            Core:Print("Up-to-date. The reliability of this statement is directly related to number of guildies online.")
        end

        if not isUpToDate then
            local formattedDate = Core:FormatTimestamp(knownLatestVersionDate)
            Core:Print("Newer dkp data found from "..formattedDate..". By "..knownLatestVersionOwner..".")
        end
    else
        -- No history or version to check, so probably brand new install.
        Core:Print("No ThirtyDKP data found. If new installation, go raiding or request broadcast from admins.")
    end
end


function Core:CheckDataVersion()
    Core:Print("Attempting to sync DKP data with online guildies.")
    -- Request data versions from online members
    local latestKnownVersion = Core:GetLatestKnownVersion()
    Core:RequestDataVersionSync(latestKnownVersion)

    C_Timer.After(6, CompareDataVersions)
end
