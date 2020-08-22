local addonName, ThirtyDKP = ...   

local View = ThirtyDKP.View
local DAL = ThirtyDKP.DAL
local Core = ThirtyDKP.Core

function Core:ImportFromMonolithDKP()
    if Core:IsAddonAdmin() then
        StaticPopupDialogs["FULL_MONOLITHDKP_IMPORT_WARNING"] = {
            text = "Warning! Do you want to completely wipe local data and import from MonolithDKP?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                if not DAL:WipeDKPTableAndImportFromMonolith() then
                    Core:Print("Could not find Monolith DKP data.")
                end
                
                -- todo: history and maybe options ??
                DAL:WipeAndSetNewHistory({})
                StaticPopup_Hide ("FULL_MONOLITHDKP_IMPORT_WARNING")
                View:UpdateAllViews();
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show ("FULL_MONOLITHDKP_IMPORT_WARNING") 
    else
        Core:Print("You are not admin.. you pleb.")
    end
end
