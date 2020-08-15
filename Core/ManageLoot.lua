local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View

local lootAnnouncedForBoss = false;

function Core:SetLootAnnouncedForBoss(isAnnounced)
  lootAnnouncedForBoss = isAnnounced;
end

function Core:HandleLootWindow()
  if not Core:IsPlayerMasterLooter() then return end
  local foundEpaxx = false

  for i = 1, GetNumLootItems() do
    local itemLink = GetLootSlotLink(i)
    if itemLink ~= nil then
      local _, _, itemRarity = GetItemInfo(itemLink);
      if itemRarity > 3 then
        foundEpaxx = true
        DAL:AddToLootTable(itemLink)
        if not lootAnnouncedForBoss then
          SendChatMessage("ThirtyDKP: "..itemLink.." is now available for bidding. ", "RAID", nil, nil)
        end
      end
    end
  end

  if foundEpaxx then
    lootAnnouncedForBoss = true;
    View:ToggleBidAnnounceFrame();
  end
end


function Core:ManualBidAnnounce(itemLink)
  if not Core:IsPlayerMasterLooter() then 
    Core:Print("You need to be in a raid and master looter to announce bids!")
    return 
  end

  if itemLink ~= nil and itemLink ~= "" then
    -- pcall is lua try catch
    if pcall(function () 
      local _, _, itemRarity = GetItemInfo(itemLink);
      if itemRarity > 3 then
        DAL:AddToLootTable(itemLink);
      end
    end) then
      Core:Print("Opening bid announcer for "..itemLink.."" );
      View:OpenBidAnnounceFrame(itemLink)
    else
      Core:Print("Invalid itemlink. Please use command like this: \"/tdkp bid itemlink\" ")
    end
  else
    View:OpenBidAnnounceFrame();
  end
end
