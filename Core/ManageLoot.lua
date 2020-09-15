local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View

local lootSources = {};

local lootAnnounceQueue = {};

local function LootHasBeenAnnounced()
  local hasBeenAnnounced = false
  local numberOfLootItems = GetNumLootItems()
  for i = 1, numberOfLootItems do
    if GetLootSlotType(i) == 1 then
      for j = 1, numberOfLootItems do
        if GetLootSourceInfo(i) == lootSources[j] then 
          hasBeenAnnounced = true
        break
        end
      end
    end
  end
  return hasBeenAnnounced
end

function Core:HandleGetItemInfoRecieved(itemdID, success)
  if #lootAnnounceQueue > 0 then
    if success then
      local _, itemLink, itemRarity = GetItemInfo(itemdID);

      for i, queuedLink in ipairs(lootAnnounceQueue) do
        if queuedLink == itemLink then
          if itemRarity > 3 then

            DAL:AddToLootTable(queuedLink);
            SendChatMessage("ThirtyDKP: "..queuedLink.." is now available for bidding. ", "RAID", nil, nil);
            table.remove(lootAnnounceQueue, queuedLink);
          end
        end
      end
      View:UpdateLootTableFrame();
    end
  else
    Core:UnregisterForGetItemInfoEvents()
  end
end


function Core:HandleLootWindow()
  if not Core:IsPlayerMasterLooter() or not Core:IsRaidStarted() or LootHasBeenAnnounced() then return end
  local foundEpaxx = false
  local numberOfLootItems = GetNumLootItems();

  for i = 1, numberOfLootItems do
    local itemLink = GetLootSlotLink(i)
    if itemLink ~= nil then
      local _, _, itemRarity = GetItemInfo(itemLink);
      if itemRarity == nil then
        -- if item not in cache, put it in queue and wait for it to arrive.
        table.insert(lootAnnounceQueue, itemLink);
        Core:RegisterForGetItemInfoEvents();
      else

        if itemRarity > 3 then
          foundEpaxx = true
          DAL:AddToLootTable(itemLink)
          SendChatMessage("ThirtyDKP: "..itemLink.." is now available for bidding. ", "RAID", nil, nil)
        end
      end
    end
  end

  if foundEpaxx then
    for i = 1, numberOfLootItems do
      lootSources[i] = GetLootSourceInfo(i)
    end
    View:UpdateLootTableFrame();
    View:OpenBidAnnounceFrame();
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
      else
        Core:Print("Bidding is only available for items of epic or legendary quality." );
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
