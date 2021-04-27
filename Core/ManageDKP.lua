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
    if raidId == 533 then
        return "naxxramas";
	elseif raidId == 531 then
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

local function GetDKPCostByEquipLocation(itemEquipLoc, raidName)
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
		return options.itemCosts.offhand;
    elseif itemEquipLoc == "INVTYPE_2HWEAPON" then
        return options.itemCosts.twoHandedWeapon
    elseif itemEquipLoc == "INVTYPE_WEAPONMAINHAND" then
        return options.itemCosts.oneHandedWeapon
    elseif itemEquipLoc == "INVTYPE_WEAPONOFFHAND" then
        return options.itemCosts.oneHandedWeapon
    elseif itemEquipLoc == "INVTYPE_HOLDABLE" then
		return options.itemCosts.offhand;
    elseif itemEquipLoc == "INVTYPE_RANGED" or itemEquipLoc == "INVTYPE_THROWN" or itemEquipLoc == "INVTYPE_RANGEDRIGHT"then
        return options.itemCosts.rangedWeapon
    else 
        return options.itemCosts.default
    end
end

function Core:GetDKPCostByItemlink(itemLink, raidName)
    local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink);
    local itemDKPCost = GetDKPCostByEquipLocation(itemEquipLoc, raidName);
    return itemDKPCost
end

local function DKPEvent(affectedPlayers, amount, reason, historyEntry)
    -- add or delete event to local history, since i am admin.
    local newHistoryEntry = {}
    if reason == "RevertHistory" and historyEntry ~= nil then
        DAL:DeleteHistoryEntry(historyEntry);
    else
        newHistoryEntry = DAL:AddToHistory(affectedPlayers, amount, reason)
    end

    -- save current (previous) table versions for broadcast
    local currentHistoryVersion = DAL:GetDKPHistoryVersion();
    -- update table versions
    DAL:UpdateDKPHistoryVersion()
    DAL:UpdateDKPTableVersion()

    -- broadcast event
    if reason == "RevertHistory" and historyEntry ~= nil then
        Core:SendRevertDKPEventMessage(historyEntry, lastHistoryVersion)
    else
        Core:SendDKPEventMessage(newHistoryEntry, currentHistoryVersion)
    end

    -- update view
    View:UpdateAllViews()
end

local function GiveStandbyDKP(listOfAwardedPlayers, dkpAmount, reason)
    if DAL:GetIncludeStandbys() then
        local standbys = DAL:GetStandbys();

        for _, playerName in ipairs(standbys) do
            if DAL:AdjustPlayerDKP(playerName, tonumber(dkpAmount)) then
                if listOfAwardedPlayers == "" then
                    listOfAwardedPlayers = playerName;
                else
                    listOfAwardedPlayers = listOfAwardedPlayers..","..playerName;
                end
            else
                Core:Print("Could not award "..playerName.." standby DKP. Contact authors.")
            end
        end
        return listOfAwardedPlayers;
    else
        return listOfAwardedPlayers;
    end
end

function Core:AwardItem(dkpTableEntry, itemLink, itemDKPCost)
    if DAL:AdjustPlayerDKP(dkpTableEntry.player, tonumber("-"..itemDKPCost)) then
        
        SendChatMessage(dkpTableEntry.player.." won "..itemLink.." ", "RAID", nil, nil)
        DKPEvent(dkpTableEntry.player, tonumber("-"..itemDKPCost), "Loot: "..itemLink)
    else
        Core:Print("Could not award "..dkpTableEntry.player.." with "..itemLink.." ");
    end 
end

function Core:HandleBossKill(eventId, ...)
    if not Core:IsRaidStarted() then return end
    local bossName = ...;
    C_Timer.After(2, function()
        
        local shouldAwardDKP = false;
        for _, bossEventId in ipairs(bossEventIds) do
            if bossEventId == eventId then
                shouldAwardDKP = true
                break;
            end
        end
        if not shouldAwardDKP then return end

        local _, _, _, _, _, _, _, instanceMapId, _ = GetInstanceInfo()
        local thirtyDKPRaidName = GetRaidNameFromId(instanceMapId);
        if thirtyDKPRaidName == "" or thirtyDKPRaidName == nil then return end

        local bossKillDKPAward = DAL:GetRaidOptions(thirtyDKPRaidName).dkpGainPerKill; -- nil value

        if bossKillDKPAward == 0 then
            return
        end

        local playerName, playerClass;
        local listOfAwardedPlayers = "";
        -- for every person in the raid
        for i=1, GetNumGroupMembers() do
            playerName, _, _, _, playerClass  = GetRaidRosterInfo(i)
            
            if DAL:AdjustPlayerDKP(playerName, tonumber(bossKillDKPAward)) then
                if listOfAwardedPlayers == "" then
                    listOfAwardedPlayers = playerName;
                else
                    listOfAwardedPlayers = listOfAwardedPlayers..","..playerName;
                end
            else
                -- could not adjust player dkp, add player to dkp table first
                DAL:AddToDKPTable(playerName, playerClass)
                if DAL:AdjustPlayerDKP(playerName, tonumber(bossKillDKPAward)) then
                    if listOfAwardedPlayers == "" then
                        listOfAwardedPlayers = playerName;
                    else
                        listOfAwardedPlayers = listOfAwardedPlayers..","..playerName;
                    end
                else
                    Core:Print("Could not award "..playerName.." boss kill DKP. Contact authors.")
                end
            end
        end

        listOfAwardedPlayers = GiveStandbyDKP(listOfAwardedPlayers, bossKillDKPAward, "Boss Kill: "..bossName)
        DKPEvent(listOfAwardedPlayers, bossKillDKPAward, "Boss Kill: "..bossName)
    
    end)
end

function Core:ApplyOnTimeBonus()
	local listOfAwardedPlayers = "";
	local onTimeBonus = DAL:GetOptions().onTimeBonus;

	for i=1, GetNumGroupMembers() do
        local playerName, _, _, _, playerClass = GetRaidRosterInfo(i)

		if DAL:AdjustPlayerDKP(playerName, onTimeBonus) then
            if listOfAwardedPlayers == "" then
                listOfAwardedPlayers = playerName;
            else
                listOfAwardedPlayers = listOfAwardedPlayers..","..playerName;
            end
		elseif Core:IsInSameGuild(playerName) then
            if DAL:AddToDKPTable(playerName, playerClass) then
                Core:Print("added "..playerName.." successfully to table.")
				DAL:AdjustPlayerDKP(playerName, onTimeBonus);
				if listOfAwardedPlayers == "" then
                    listOfAwardedPlayers = playerName;
                else
                    listOfAwardedPlayers = listOfAwardedPlayers..","..playerName;
                end
            end
		end
	end

    listOfAwardedPlayers = GiveStandbyDKP(listOfAwardedPlayers, onTimeBonus, "On Time Bonus")
    DKPEvent(listOfAwardedPlayers, onTimeBonus, "On Time Bonus")
end

function Core:ApplyRaidEndBonus()
	local listOfAwardedPlayers = "";
	local raidCompletionBonus = DAL:GetOptions().raidCompletionBonus;

	for i=1, GetNumGroupMembers() do
        local playerName, _, _, _, playerClass = GetRaidRosterInfo(i)

		if DAL:AdjustPlayerDKP(playerName, raidCompletionBonus) then
            if listOfAwardedPlayers == "" then
                listOfAwardedPlayers = playerName;
            else
                listOfAwardedPlayers = listOfAwardedPlayers..","..playerName;
            end
            
		elseif Core:IsInSameGuild(playerName) then
            if DAL:AddToDKPTable(playerName, playerClass) then
                Core:Print("added "..playerName.." successfully to table.")
				DAL:AdjustPlayerDKP(playerName, raidCompletionBonus);

				if listOfAwardedPlayers == "" then
                    listOfAwardedPlayers = playerName;
                else
                    listOfAwardedPlayers = listOfAwardedPlayers..","..playerName;
                end
            end
		end
	end

    listOfAwardedPlayers = GiveStandbyDKP(listOfAwardedPlayers, raidCompletionBonus, "Raid Completion Bonus")
    DKPEvent(listOfAwardedPlayers, raidCompletionBonus, "Raid Completion Bonus")
end

function Core:ApplyDecay()
    local listOfAwardedPlayers = "";
    local listOfAdjustedDecay = "";
    local decayPercentage = DAL:GetOptions().decay;
    local decay = decayPercentage / 100.0;
    
    for i, dkpEntry in ipairs(DAL:GetDKPTable()) do
        local decayAmount = math.floor(dkpEntry.dkp * decay);

        if DAL:AdjustPlayerDKP(dkpEntry.player, -decayAmount) then
            if listOfAwardedPlayers == "" then
                listOfAwardedPlayers = dkpEntry.player;
                listOfAdjustedDecay = tostring(-decayAmount);
            else
                listOfAwardedPlayers = listOfAwardedPlayers..","..dkpEntry.player;
                listOfAdjustedDecay = listOfAdjustedDecay..","..tostring(-decayAmount);
            end
        end
    end

    DKPEvent(listOfAwardedPlayers, listOfAdjustedDecay, "Decay:-"..tostring(decayPercentage).."%")
end

function Core:RevertHistory(historyEntry)
    local maybeDecay, _ = string.split(":", historyEntry.reason)
    local isDecayEntry = maybeDecay == "Decay";
    local playerArray = {string.split(",", historyEntry.players)}
    local dkpAdjust = {}

    if isDecayEntry then
        dkpAdjust = {string.split(",", historyEntry.dkp)}
    else
        table.insert(dkpAdjust, -historyEntry.dkp)
    end
    
    for i, player in ipairs(playerArray) do
        if player ~= nil and player ~= "" then
            if isDecayEntry then
                DAL:AdjustPlayerDKP(player, -tonumber(dkpAdjust[i]));
            else
                DAL:AdjustPlayerDKP(player, dkpAdjust[1]);
            end
        end
    end
    
    DKPEvent(historyEntry.players, historyEntry.dkp, "RevertHistory", historyEntry)
end

function Core:AdjustPlayersDKP(selectedPlayers, DkpAdjustAmount, DkpAdjustReason)
    local listOfAdjustedPlayers = "";

    for i, selectedPlayer in ipairs(selectedPlayers) do
        if DAL:AdjustPlayerDKP(selectedPlayer, DkpAdjustAmount) then
            if listOfAdjustedPlayers == "" then
                listOfAdjustedPlayers = selectedPlayer;
            else
                listOfAdjustedPlayers = listOfAdjustedPlayers..","..selectedPlayer;
            end
        end
    end

    DKPEvent(listOfAdjustedPlayers, DkpAdjustAmount, DkpAdjustReason)
end
