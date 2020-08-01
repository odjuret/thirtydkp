local addonName, ThirtyDKP = ...   

local DAL = ThirtyDKP.DAL
local Core = ThirtyDKP.Core

local classColors = {
	["Druid"] = "FF7D0A",
	["Hunter"] =  "ABD473",
	["Mage"] = "40C7EB",
	["Priest"] = "FFFFFF",
	["Rogue"] = "FFF569",
	["Shaman"] = "F58CBA",
	["Paladin"] = "F58CBA",
	["Warlock"] = "8787ED",
	["Warrior"] = "C79C6E"
}

function Core:Print(args)
    print("|cffffcc00[ThirtyDKP]:|r |cffa30f2d"..args.."|r")
end

function Core:AddClassColor(stringToColorize, class)
    local classColor = classColors[class]
    
    return "|cff"..classColor..stringToColorize.."|r"
end

function Core:TryToAddClassColor(playerName)
    local playerEntry = DAL:GetFromDKPTable(playerName)

    if playerEntry ~= false then
        return Core:AddClassColor(playerName, playerEntry.class)
    else
        return playerName
    end
end


function Core:ColorizeAndBreakPlayers(playersString)
    if string.sub(playersString, 1, 3) == ", " then
        playersString = string.sub(playersString, 3)
    end
    
    local colorizedArray = ""
    local breakIndex = 1
    for i, player in ipairs({strsplit(", ", playersString)}) do
        if player ~= nil and player ~= "" then
            local separator = ", "
            local columnToAdd = player
            local playerEntry = DAL:GetFromDKPTable(player)

            if playerEntry ~= false then
                columnToAdd = Core:AddClassColor(player, playerEntry.class)
            end
            if (breakIndex % 10) == 0 then
                separator = ",\n"
            end
            colorizedArray = colorizedArray..columnToAdd..separator
            breakIndex = breakIndex +1;
        end
    end
    local rows = Core:RoundNumber((breakIndex/10),0)
    if rows > 0 then
        rows = rows -1
    end

    return colorizedArray, rows
end

function Core:ColorizePositiveOrNegative(number, stringToColorize)
    local colorizedString = ""
    if number < 0 then
        colorizedString = "|cffDC143C"..stringToColorize.."|r"
    else
        colorizedString = "|cff32CD32"..stringToColorize.."|r"
    end
    return colorizedString;
end

function Core:ColorizeListHeader(stringToColorize)
    return "|cffaeaedd"..stringToColorize.."|r"
end
