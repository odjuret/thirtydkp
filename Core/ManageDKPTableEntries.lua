local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL

local bossEventIds = {  
        -- MC 
        663, 664, 665,
        666, 668, 667, 669, 
        670, 671, 672,
        -- BWL
        610, 611, 612,
        613, 614, 615, 616, 
        617,
        -- AQ
        709, 711, 712,
        714, 715, 717, 
        710, 713, 716,
        -- Naxx
        1107, 1110, 1116,
        1117, 1112, 1115, 
        1113, 1109, 1121,
        1118, 1111, 1108, 1120,
        1119, 1114,
        -- ZG
        787, 790, 793, 789, 784, 791,
        785, 792, 786, 788,
        -- AQ20
        722, 721, 719, 718, 720, 723,
        -- Onyxia
        1084
}

local function GetDKPCostByEquipLocation(itemEquipLoc)
    local thirtyDkpOptions = DAL:GetOptions();
    if not itemEquipLoc then
        return thirtyDkpOptions.itemCosts.default
    end

    if itemEquipLoc == "INVTYPE_HEAD" then
        return thirtyDkpOptions.itemCosts.head
    elseif itemEquipLoc == "INVTYPE_NECK" then
        return thirtyDkpOptions.itemCosts.neck
    elseif itemEquipLoc == "INVTYPE_SHOULDER" then
        return thirtyDkpOptions.itemCosts.shoulders
    elseif itemEquipLoc == "INVTYPE_CHEST" or itemEquipLoc == "INVTYPE_ROBE" then
        return thirtyDkpOptions.itemCosts.chest
    elseif itemEquipLoc == "INVTYPE_WAIST" then
        return thirtyDkpOptions.itemCosts.belt
    elseif itemEquipLoc == "INVTYPE_HAND" then
        return thirtyDkpOptions.itemCosts.gloves
    elseif itemEquipLoc == "INVTYPE_LEGS" then
        return thirtyDkpOptions.itemCosts.legs
    elseif itemEquipLoc == "INVTYPE_FEET" then
        return thirtyDkpOptions.itemCosts.boots
    elseif itemEquipLoc == "INVTYPE_WRIST" then
        return thirtyDkpOptions.itemCosts.bracers
    elseif itemEquipLoc == "INVTYPE_FINGER" then
        return thirtyDkpOptions.itemCosts.ring
    elseif itemEquipLoc == "INVTYPE_TRINKET" then
        return thirtyDkpOptions.itemCosts.trinket
    elseif itemEquipLoc == "INVTYPE_CLOAK" then
        return thirtyDkpOptions.itemCosts.back
    elseif itemEquipLoc == "INVTYPE_WEAPON" then
        return thirtyDkpOptions.itemCosts.oneHandedWeapon
    elseif itemEquipLoc == "INVTYPE_SHIELD" then
    elseif itemEquipLoc == "INVTYPE_2HWEAPON" then
        return thirtyDkpOptions.itemCosts.twoHandedWeapon
    elseif itemEquipLoc == "INVTYPE_WEAPONMAINHAND" then
        return thirtyDkpOptions.itemCosts.oneHandedWeapon
    elseif itemEquipLoc == "INVTYPE_WEAPONOFFHAND" then
        return thirtyDkpOptions.itemCosts.oneHandedWeapon
    elseif itemEquipLoc == "INVTYPE_HOLDABLE" then
    elseif itemEquipLoc == "INVTYPE_RANGED" or itemEquipLoc == "INVTYPE_THROWN" or itemEquipLoc == "INVTYPE_RANGEDRIGHT"then
        return thirtyDkpOptions.itemCosts.rangedWeapon
    else 
        return thirtyDkpOptions.itemCosts.default
    end
end

function Core:GetDKPCostByItemlink(itemLink)
    local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink);
    local itemDKPCost = GetDKPCostByEquipLocation(itemEquipLoc);
    return itemDKPCost
end


function Core:AwardItem(dkpTableEntry, itemLink, itemDKPCost)
    if DAL:AdjustPlayerDKP(dkpTableEntry.player, tonumber("-"..itemDKPCost)) then
        Core:Announce(dkpTableEntry.player.." won "..itemLink.." ");
        -- add event to history
        DAL:AddToHistory(dkpTableEntry.player, tonumber("-"..itemDKPCost), "Loot: "..itemLink)
        -- update table versions
        DAL:UpdateDKPHistoryVersion()
        DAL:UpdateDKPTableVersion()
        -- broadcast event
        Core:SendDKPEventMessage(dkpTableEntry.player, tonumber("-"..itemDKPCost), "Loot: "..itemLink)
    else
        Core:Announce("Could not award "..dkpTableEntry.player.." with "..itemLink.." ");
    end 
end

function Core:HandleBossKill(eventId, ...)
    if not Core:IsPlayerMasterLooter() or not Core:IsRaidStarted() then return end
    
    local bossName = ...;
    local shouldAwardDKP = false;
    for _, bossEventId in ipairs(bossEventIds) do
        if bossEventId == eventId then
            shouldAwardDKP = true
            break;
        end
    end
    if not shouldAwardDKP then return end
    -- todo: add options check if raid zone should award dkp

    local bossKillDKPAward = DAL:GetOptions().dkpGainPerKill;
    local playerName, playerClass;
    local listOfAwardedPlayers = "";
    -- for every person in the raid
    for i=1, GetNumGroupMembers() do
        playerName, _, _, _, playerClass  = GetRaidRosterInfo(i)
        
        if DAL:AdjustPlayerDKP(playerName, tonumber(bossKillDKPAward)) then
            listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName
        else
            -- could not adjust player dkp, add player to dkp table first
            DAL:AddToDKPTable(playerName, playerClass)
            if DAL:AdjustPlayerDKP(playerName, tonumber(bossKillDKPAward)) then
                listOfAwardedPlayers = listOfAwardedPlayers..playerName..","
            else
                Core:Print("Could not award "..playerName.." boss kill DKP. Contact authors.")
            end
        end 
    end
    -- add event to history
    DAL:AddToHistory(listOfAwardedPlayers, bossKillDKPAward, "Boss Kill: "..bossName)
    -- update table versions
    DAL:UpdateDKPHistoryVersion()
    DAL:UpdateDKPTableVersion()
    -- broadcast event
    Core:SendDKPEventMessage(listOfAwardedPlayers, bossKillDKPAward, "Boss Kill: "..bossName)
end

local function IsInSameGuild(playerName)
	for i=1, GetNumGuildMembers() do
		nameFromGuild, _, _, _, _ = GetGuildRosterInfo(i)

		nameFromGuild = strsub(nameFromGuild, 1, string.find(nameFromGuild, "-")-1) -- required to remove server name from player (can remove in classic if this is not an issue)
		if nameFromGuild == playerName then
			return true;
		end
	end

	return false;
end


function Core:AddRaidToDKPTable()
    for i=1, GetNumGroupMembers() do
        local playerName, _, _, _, playerClass = GetRaidRosterInfo(i)
        
		if playerName and IsInSameGuild(playerName) then
            if DAL:AddToDKPTable(playerName, playerClass) then
                Core:Print("added "..playerName.." successfully to table.")
            end
		end
    end
end

function Core:AddGuildToDKPTable()
    local guildSize = GetNumGuildMembers();
    local nameFromGuild, rank, rankIndex, tempClass;
    
    -- for every person in the guild
    for i=1, guildSize do
        nameFromGuild, rank, rankIndex, _, tempClass = GetGuildRosterInfo(i)
        nameFromGuild = strsub(nameFromGuild, 1, string.find(nameFromGuild, "-")-1) -- required to remove server name from player (can remove in classic if this is not an issue)
        
        -- TODO: user be able to choose rank
        if rankIndex < 2 then
            if DAL:AddToDKPTable(nameFromGuild, tempClass) then
                Core:Print("added "..nameFromGuild.." successfully to table.")
            end
        end
    end
end


function Core:ApplyOnTimeBonus()
	local listOfAwardedPlayers = "";
	local onTimeBonus = DAL:GetOptions().onTimeBonus;

	for i=1, GetNumGroupMembers() do
        local playerName, _, _, _, playerClass = GetRaidRosterInfo(i)

		if DAL:AdjustPlayerDKP(playerName, onTimeBonus) then
            listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
		elseif IsInSameGuild(playerName) then
            if DAL:AddToDKPTable(playerName, playerClass) then
                Core:Print("added "..playerName.." successfully to table.")
				listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
            end
		end
	end

	DAL:AddToHistory(listOfAwardedPlayers, onTimeBonus, "On Time Bonus");
	DAL:UpdateDKPHistoryVersion()
	DAL:UpdateDKPTableVersion()
	Core:SendDKPEventMessage(listOfAwardedPlayers, onTimeBonus, "On Time Bonus")
end


function Core:ApplyRaidEndBonus()
	local listOfAwardedPlayers = "";
	local raidCompletionBonus = DAL:GetOptions().raidCompletionBonus;

	for i=1, GetNumGroupMembers() do
        local playerName, _, _, _, playerClass = GetRaidRosterInfo(i)

		if DAL:AdjustPlayerDKP(playerName, raidCompletionBonus) then
            listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
		elseif IsInSameGuild(playerName) then
            if DAL:AddToDKPTable(playerName, playerClass) then
                Core:Print("added "..playerName.." successfully to table.")
				listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
            end
		end

		DAL:AddToHistory(listOfAwardedPlayers, raidCompletionBonus, "Raid Completion Bonus");
		DAL:UpdateDKPHistoryVersion()
		DAL:UpdateDKPTableVersion()
		Core:SendDKPEventMessage(listOfAwardedPlayers, raidCompletionBonus, "Raid Completion Bonus")
	end
end
