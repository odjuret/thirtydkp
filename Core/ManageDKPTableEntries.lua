local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core

function Core:AddRaidToDKPTable()
    local tempName,tempClass;
    local guildSize = GetNumGuildMembers();
    local name, rank, rankIndex;


    for i=1, 40 do
        tempName,_,_,_,_,tempClass = GetRaidRosterInfo(i)
        print("ThirtyDKP: raidmember: "..tostring(i)..". name: "..tostring(tempName)..". class: "..tostring(tempClass) )
        -- TODO: Jimmie left off here
    end
end
