local addonName, ThirtyDKP = ...

local DAL = ThirtyDKP.DAL

local SORT_ASCENDING = "Ascending"
local SORT_DESCENDING = "Descending"


function DAL:InitializeOptions()
	if not ThirtyDKP_Database_Options then
		ThirtyDKP_Database_Options = {
			dkpGainPerKill = 0,
			itemCosts = {
				head = 0,
				neck = 0,
				shoulders = 0,
				back = 0,
				chest = 0,
				bracers = 0,
				gloves = 0,
				belt = 0,
				legs = 0,
				boots = 0,
				ring = 0,
				trinket = 0,
				oneHandedWeapon = 0,
				twoHandedWeapon = 0,
				rangedWeapon = 0,
				default = 10,
			},
			dkpTableSorting = {
				column = "player",
				mode = "Ascending"
			}
		};
	end
end

function DAL:GetOptions()
	return ThirtyDKP_Database_Options;
end

function DAL:GetDKPTableSorting()
	return ThirtyDKP_Database_Options.dkpTableSorting;
end

function DAL:ToggleDKPTableSorting(column)
	if ThirtyDKP_Database_Options.dkpTableSorting.column == column then
		if ThirtyDKP_Database_Options.dkpTableSorting.mode == SORT_ASCENDING then
			ThirtyDKP_Database_Options.dkpTableSorting.mode = SORT_DESCENDING
		else
			ThirtyDKP_Database_Options.dkpTableSorting.mode = SORT_ASCENDING
		end
	else
		ThirtyDKP_Database_Options.dkpTableSorting.column = column
	end
end