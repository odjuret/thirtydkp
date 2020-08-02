local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View;

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


local function GetRaidNameFromId(raidId)
	if raidId == 531 then
		return "aq40";
	elseif raidId == 469 then
		return "bwl";
	elseif raidId == 409 then
		return "mc";
	elseif raidId == 249 then
		return "onyxia";
	else
		return "";
	end
end

function Core:CheckRaid()
    local _, _, _, _, _, _, _, instanceMapId, _ = GetInstanceInfo();
    local raidName = GetRaidNameFromId(instanceMapId);
    if raidName ~= "" then
        DAL:SetLastKnownRaid(raidName);
    end
end


local function GetDKPCostByEquipLocation(itemEquipLoc)
    local _, _, _, _, _, _, _, instanceMapId, _ = GetInstanceInfo();
    local raidName = GetRaidNameFromId(instanceMapId);
    if raidName == "" then
        raidName = DAL:GetLastOrDefaultRaid();
    end
    
    local options = DAL:GetRaidOptions(raidName);

    if not itemEquipLoc then
        return options.itemCosts.default
    end

    if itemEquipLoc == "INVTYPE_HEAD" then
        return options.itemCosts.head
    elseif itemEquipLoc == "INVTYPE_NECK" then
        return options.itemCosts.neck
    elseif itemEquipLoc == "INVTYPE_SHOULDER" then
        return options.itemCosts.shoulders
    elseif itemEquipLoc == "INVTYPE_CHEST" or itemEquipLoc == "INVTYPE_ROBE" then
        return options.itemCosts.chest
    elseif itemEquipLoc == "INVTYPE_WAIST" then
        return options.itemCosts.belt
    elseif itemEquipLoc == "INVTYPE_HAND" then
        return options.itemCosts.gloves
    elseif itemEquipLoc == "INVTYPE_LEGS" then
        return options.itemCosts.legs
    elseif itemEquipLoc == "INVTYPE_FEET" then
        return options.itemCosts.boots
    elseif itemEquipLoc == "INVTYPE_WRIST" then
        return options.itemCosts.bracers
    elseif itemEquipLoc == "INVTYPE_FINGER" then
        return options.itemCosts.ring
    elseif itemEquipLoc == "INVTYPE_TRINKET" then
        return options.itemCosts.trinket
    elseif itemEquipLoc == "INVTYPE_CLOAK" then
        return options.itemCosts.back
    elseif itemEquipLoc == "INVTYPE_WEAPON" then
        return options.itemCosts.oneHandedWeapon
    elseif itemEquipLoc == "INVTYPE_SHIELD" then
    elseif itemEquipLoc == "INVTYPE_2HWEAPON" then
        return options.itemCosts.twoHandedWeapon
    elseif itemEquipLoc == "INVTYPE_WEAPONMAINHAND" then
        return options.itemCosts.oneHandedWeapon
    elseif itemEquipLoc == "INVTYPE_WEAPONOFFHAND" then
        return options.itemCosts.oneHandedWeapon
    elseif itemEquipLoc == "INVTYPE_HOLDABLE" then
    elseif itemEquipLoc == "INVTYPE_RANGED" or itemEquipLoc == "INVTYPE_THROWN" or itemEquipLoc == "INVTYPE_RANGEDRIGHT"then
        return options.itemCosts.rangedWeapon
    else 
        return options.itemCosts.default
    end
end

function Core:GetDKPCostByItemlink(itemLink)
    local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink);
    local itemDKPCost = GetDKPCostByEquipLocation(itemEquipLoc);
    return itemDKPCost
end


function Core:AwardItem(dkpTableEntry, itemLink, itemDKPCost)
    if DAL:AdjustPlayerDKP(dkpTableEntry.player, tonumber("-"..itemDKPCost)) then
        Core:RaidAnnounce(dkpTableEntry.player.." won "..itemLink.." ");
        -- add event to history
        DAL:AddToHistory(dkpTableEntry.player, tonumber("-"..itemDKPCost), "Loot: "..itemLink)
        -- update table versions
        DAL:UpdateDKPHistoryVersion()
        DAL:UpdateDKPTableVersion()
        -- broadcast event
        Core:SendDKPEventMessage(dkpTableEntry.player, tonumber("-"..itemDKPCost), "Loot: "..itemLink)
        -- update view
        View:UpdateDKPTable();
    else
        Core:RaidAnnounce("Could not award "..dkpTableEntry.player.." with "..itemLink.." ");
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

	local _, _, _, _, _, _, _, instanceMapId, _ = GetInstanceInfo()
    local bossKillDKPAward = DAL:GetRaidOptions(GetRaidNameFromId(instanceMapId)).dkpGainPerKill;
    local playerName, playerClass;
    local listOfAwardedPlayers = "";
    -- for every person in the raid
    for i=1, GetNumGroupMembers() do
        playerName, _, _, _, playerClass  = GetRaidRosterInfo(i)
        
        if DAL:AdjustPlayerDKP(playerName, tonumber(bossKillDKPAward)) then
            if i == 1 then
                listOfAwardedPlayers = playerName;
            else
                listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
            end
        else
            -- could not adjust player dkp, add player to dkp table first
            DAL:AddToDKPTable(playerName, playerClass)
            if DAL:AdjustPlayerDKP(playerName, tonumber(bossKillDKPAward)) then
                if i == 1 then
                    listOfAwardedPlayers = playerName;
                else
                    listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
                end
            else
                Core:Print("Could not award "..playerName.." boss kill DKP. Contact authors.")
            end
        end
    end
    -- add event to history
    DAL:AddToHistory(listOfAwardedPlayers, bossKillDKPAward, "Boss Kill: "..bossName)
    -- update table versions (since only master looters get here)
    DAL:UpdateDKPHistoryVersion()
    DAL:UpdateDKPTableVersion()
    -- broadcast event
    Core:SendDKPEventMessage(listOfAwardedPlayers, bossKillDKPAward, "Boss Kill: "..bossName)
	View:UpdateDKPTable();
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
    local playersAdded = "";
    
    -- for every person in the guild
    for i=1, guildSize do
        nameFromGuild, rank, rankIndex, _, tempClass = GetGuildRosterInfo(i)
        nameFromGuild = strsub(nameFromGuild, 1, string.find(nameFromGuild, "-")-1) -- required to remove server name from player (can remove in classic if this is not an issue)
        
        -- TODO: user be able to choose rank
        if rankIndex <= 4 then
            if DAL:AddToDKPTable(nameFromGuild, tempClass) then
                if playersAdded == "" then
                    playersAdded = Core:AddClassColor(nameFromGuild, tempClass)
                else
                    playersAdded = playersAdded..", "..Core:AddClassColor(nameFromGuild, tempClass)
                end
            end
        end
    end
    if playersAdded == "" then
        Core:Print("No more players above "..rank.." found.")
    else
        Core:Print("added "..playersAdded.." successfully to table.")
    end
end


function Core:ApplyOnTimeBonus()
	local listOfAwardedPlayers = "";
	local onTimeBonus = DAL:GetOptions().onTimeBonus;

	for i=1, GetNumGroupMembers() do
        local playerName, _, _, _, playerClass = GetRaidRosterInfo(i)

		if DAL:AdjustPlayerDKP(playerName, onTimeBonus) then
            if i == 1 then
                listOfAwardedPlayers = playerName;
            else
                listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
            end
		elseif IsInSameGuild(playerName) then
            if DAL:AddToDKPTable(playerName, playerClass) then
                Core:Print("added "..playerName.." successfully to table.")
				DAL:AdjustPlayerDKP(playerName, raidCompletionBonus);
				if i == 1 then
                    listOfAwardedPlayers = playerName;
                else
                    listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
                end
            end
		end
	end

	DAL:AddToHistory(listOfAwardedPlayers, onTimeBonus, "On Time Bonus");
	DAL:UpdateDKPHistoryVersion()
	DAL:UpdateDKPTableVersion()
	Core:SendDKPEventMessage(listOfAwardedPlayers, onTimeBonus, "On Time Bonus")
	View:UpdateDKPTable();
end


function Core:ApplyRaidEndBonus()
	local listOfAwardedPlayers = "";
	local raidCompletionBonus = DAL:GetOptions().raidCompletionBonus;

	for i=1, GetNumGroupMembers() do
        local playerName, _, _, _, playerClass = GetRaidRosterInfo(i)

		if DAL:AdjustPlayerDKP(playerName, raidCompletionBonus) then
            if i == 1 then
                listOfAwardedPlayers = playerName;
            else
                listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
            end
            
		elseif IsInSameGuild(playerName) then
            if DAL:AddToDKPTable(playerName, playerClass) then
                Core:Print("added "..playerName.." successfully to table.")
				DAL:AdjustPlayerDKP(playerName, raidCompletionBonus);

				if i == 1 then
                    listOfAwardedPlayers = playerName;
                else
                    listOfAwardedPlayers = listOfAwardedPlayers..", "..playerName;
                end
            end
		end
	end

	DAL:AddToHistory(listOfAwardedPlayers, raidCompletionBonus, "Raid Completion Bonus");
	DAL:UpdateDKPHistoryVersion()
	DAL:UpdateDKPTableVersion()
	Core:SendDKPEventMessage(listOfAwardedPlayers, raidCompletionBonus, "Raid Completion Bonus")
	View:UpdateDKPTable();
end

function Core:ApplyDecay()
	local decay = DAL:GetOptions().decay / 100.0;

	for i=1, GetNumGuildMembers() do
		local playerName = GetGuildRosterInfo(i);
        playerName = strsub(playerName, 1, string.find(playerName, "-")-1) -- required to remove server name from player (can remove in classic if this is not an issue)
		local dkpEntry = DAL:GetFromDKPTable(playerName);

		if dkpEntry then
			local decayAmount = math.floor(dkpEntry.dkp * decay);
			if DAL:AdjustPlayerDKP(playerName, -decayAmount) then
				DAL:AddToHistory(playerName, decay, "Decay");
			end
		end
	end

	DAL:UpdateDKPHistoryVersion()
	DAL:UpdateDKPTableVersion()
	View:UpdateDKPTable();
end
