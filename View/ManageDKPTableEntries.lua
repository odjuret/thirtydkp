local addonName, ThirtyDKP = ...

-- Initializing the view
local View = ThirtyDKP.View;
local Core = ThirtyDKP.Core;

function View:AttachAddRaidToTableScripts(frame)
    -- add raid to dkp table if they don't exist
	
	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText("Add raid members to DKP table", 0.25, 0.75, 0.90, 1, true);
		GameTooltip:AddLine("Given that theyre in the guild obviously", 1.0, 1.0, 1.0, true);
		GameTooltip:Show();
	end)
	frame:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
    frame:SetScript("OnClick", function ()
        -- If you aint in raid	
        if not IsInRaid() then
            StaticPopupDialogs["NOT_IN_RAID"] = {
                text = "Well you gotta be in a raid to add raid members to DKP table...",
                button1 = "Oh right...",
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
              }
              StaticPopup_Show ("NOT_IN_RAID")
        else
            -- confirmation dialog to remove user(s)
            local selected = "Sure you want to add the entire raid to the DKP table?";
            StaticPopupDialogs["ADD_RAID_ENTRIES"] = {
            text = selected,
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                Core:AddRaidToDKPTable()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            }
            StaticPopup_Show ("ADD_RAID_ENTRIES")
        end
	end);
end
