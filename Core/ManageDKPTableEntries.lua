local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View;


function Core:AddRaidToDKPTable()
    for i=1, GetNumGroupMembers() do
        local playerName, _, _, _, playerClass = GetRaidRosterInfo(i)
        
		if playerName and Core:IsInSameGuild(playerName) then
            if DAL:AddToDKPTable(playerName, playerClass) then
                Core:Print("added "..playerName.." successfully to table.")
            end
		end
    end
end

function Core:AddGuildToDKPTable(arg_selectedRank)
    local guildSize = GetNumGuildMembers();
    local nameFromGuild, rank, rankIndex, tempClass;
    local playersAdded = "";
    
    -- for every person in the guild
    for i=1, guildSize do
        nameFromGuild, rank, rankIndex, _, tempClass = GetGuildRosterInfo(i)
        nameFromGuild = strsub(nameFromGuild, 1, string.find(nameFromGuild, "-")-1) -- required to remove server name from player (can remove in classic if this is not an issue)
        
        if rank == arg_selectedRank then
            if DAL:AddToDKPTable(nameFromGuild, tempClass) then
                if playersAdded == "" then
                    playersAdded = Core:AddClassColor(nameFromGuild, tempClass)
                else
                    playersAdded = playersAdded..","..Core:AddClassColor(nameFromGuild, tempClass)
                end
            end
        end
    end
    if playersAdded == "" then
        Core:Print("No more players added to table.")
    else
        Core:Print("The following players were added to the table: "..playersAdded)
    end
end