local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL

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
                print("ThirtyDKP: added "..nameFromGuild.." successfully to table.")
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
                print("ThirtyDKP: added "..nameFromGuild.." successfully to table.")
            end
        end
    end
end
