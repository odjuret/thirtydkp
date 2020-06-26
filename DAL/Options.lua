local addonName, ThirtyDKP = ...

local DAL = ThirtyDKP.DAL

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
			}
		};
	end
end

function DAL:GetOptions()
	return ThirtyDKP_Database_Options;
end
