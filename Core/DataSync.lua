local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL

local isUpToDate = false
local recievedUpdates = 0
local knownLatestVersionOwner = nil
local knownLatestVersionDate = nil

function Core:IsDataUpToDate()
    return isUpToDate
end

local function InitializeLatestKnownVersion()
    local dkpTableVersion = DAL:GetDKPTableVersion()
	if dkpTableVersion then
		local _, localVersionOwner, localVersionDate = strsplit("-", dkpTableVersion)
		knownLatestVersionOwner = localVersionOwner
		knownLatestVersionDate = localVersionDate
	else
		knownLatestVersionDate = "";
		knownLatestVersionOwner = "";
	end
end

function Core:GetLatestKnownVersion()
    if knownLatestVersionOwner == nil then
        InitializeLatestKnownVersion()
    end
    return knownLatestVersionOwner.."-"..knownLatestVersionDate
end


function Core:TryUpdateKnownVersion(incomingVersionIndex)
    local incomingGuildname, incomingVersionOwner, incomingVersionDate = strsplit("-", incomingVersionIndex)
    local guildname = strsplit("-", DAL:GetDKPTableVersion()) 
    if not incomingGuildname == guildname then
        return;
    end
    recievedUpdates = recievedUpdates +1

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
        local dataGuildname = strsplit("-", DAL:GetDKPTableVersion())
        local currentGuildName = GetGuildInfo("player");
        if not currentGuildName == dataGuildname then
            Core:Print("Actual guild: "..currentGuildName.." mismatches with ThirtyDKP data guild name: "..dataGuildname..".")
            return;
        end

        if recievedUpdates < 4 then
            Core:Print("Not enough updates recieved. Try again when more guildies are online.")
            return;
        end

        local _, localVersionOwner, localVersionDate = strsplit("-", dkpTableVersion) 

        if tonumber(knownLatestVersionDate) <= tonumber(localVersionDate) then
            isUpToDate = true
            Core:Print("Up-to-date.");
        end

        if not isUpToDate then
            local formattedDate = Core:FormatTimestamp(knownLatestVersionDate)
            Core:Print("Newer DKP data found from "..formattedDate..". By "..knownLatestVersionOwner..".");
        end
    else
        -- No history or version to check, so probably brand new install.
        Core:Print("No ThirtyDKP data found. If new installation, go raiding or request broadcast from admins.")
    end
end


function Core:CheckDataVersion()
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
