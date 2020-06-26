local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL

local function GetDKPCostByEquipLocation(itemEquipLoc)
    local thirtyDkpOptions = DAL:GetOptions();
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


function Core:AwardItem(dkpTableEntry, itemLink)
    local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink);
    local itemDKPCost = GetDKPCostByEquipLocation(itemEquipLoc);

    if DAL:AdjustPlayerDKP(dkpTableEntry, tonumber("-"..itemDKPCost)) then
        Core:Announce(dkpTableEntry.player.." won "..itemLink.." ")
    else
        Core:Announce("Could not award "..dkpTableEntry.player.." with "..itemLink.." ")
    end 
end


function Core:AddRaidToDKPTable()
    local nameFromRaid;
    local guildSize = GetNumGuildMembers();
    local nameFromGuild, classFromGuild;
    local InGuild = false; -- Only adds player to list if the player is found in the guild roster.


    -- for every person in the raid
    for i=1, GetNumGroupMembers() do
        nameFromRaid = GetRaidRosterInfo(i)
        
        -- see if they exist in guild
        for j=1, guildSize do
            nameFromGuild, _, _, _, classFromGuild = GetGuildRosterInfo(j)

            nameFromGuild = strsub(nameFromGuild, 1, string.find(nameFromGuild, "-")-1) -- required to remove server name from player (can remove in classic if this is not an issue)
            if nameFromGuild == nameFromRaid then
                InGuild = true;
                break;
            end
        end
        if nameFromRaid and InGuild then
            if DAL:AddToDKPTable(nameFromGuild, classFromGuild) then
                Core:Print("added "..nameFromGuild.." successfully to table.")
            end
        end
        InGuild = false;
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
