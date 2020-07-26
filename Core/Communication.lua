local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View

local Communicator = LibStub("AceAddon-3.0"):NewAddon("ThirtyDKP", "AceComm-3.0")

local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

-- Channel prefixes have a max length of 16 character
local DKPTABLE_BROADCAST_CHANNEL_PREFIX = "TDKPBroadcast";
local PRINT_MSG_CHANNEL_PREFIX = "TDKPPrintMsg";
local START_BIDDING_CHANNEL_PREFIX = "TDKPStartBid";
local SUBMIT_BIDDING_CHANNEL_PREFIX = "TDKPSubmitBid";
local DKP_EVENT_CHANNEL_PREFIX = "TDKPDKPEvent";
local DATA_VERSION_SYNC_CHANNEL_PREFIX = "TDKPDataSync";
local DATA_VERSION_SYNC_RESPONSE_CHANNEL_PREFIX = "TDKPDataSyncRe";

local biddingInProgress = false
local passOnItemBidMessage = "PassOnItemForBid"

function Core:IsBiddingInProgress()
    return biddingInProgress
end

-------------------------
-- incoming communication

local function HandleDKPTableBroadcastMessage(prefix, message, distribution, sender)
    if (sender ~= UnitName("player")) then
        local decoded = LibDeflate:DecompressDeflate(LibDeflate:DecodeForWoWAddonChannel(message))
        local success, deserialized = LibAceSerializer:Deserialize(decoded);
        if success then

            StaticPopupDialogs["FULL_BROADCAST_WARNING"] = {
                text = "Warning! Incoming DKP Table broadcast. Do you trust the sender "..sender.."?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    DAL:WipeAndSetNewDKPTable(deserialized.dkpTable)
                    DAL:WipeAndSetNewOptions(deserialized.options)
                    DAL:WipeAndSetNewHistory(deserialized.history)
                    View:UpdateDKPTable()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show ("FULL_BROADCAST_WARNING")

        else
            Core:Print("DKP Table broadcasting message recieved but something went wrong... Contact Authors.")
        end

    end
end

local function HandleStartBiddingMessage(prefix, message, distribution, sender)
    local timer, itemLink = strsplit("-", message);
    View:CreateBiddingFrame(itemLink);
    Core:Print("Bidding started for: "..itemLink.."") 
    C_Timer.After(timer, function()
        View:HideBiddingFrame()
    end)   
end

local function HandlePrintMsgMessage(prefix, message, distribution, sender)
    Core:Print(""..message.."") 
end

local function HandleSubmitBidMessage(prefix, message, distribution, sender)
    if biddingInProgress then
        if message == passOnItemBidMessage then
            SendChatMessage("ThirtyDKP: "..sender.." passed on item out for bid. ", "RAID", nil, nil)
            return
        end

        Core:Print("Incoming bid from "..sender.."") 
        local player = DAL:GetFromDKPTable(sender)

        if player == false then
            local nameFromRaid, classFromRaid;

            -- for every person in the raid
            for i=1, GetNumGroupMembers() do
                nameFromRaid, _, _, _, classFromRaid = GetRaidRosterInfo(i)
                
                if nameFromRaid == sender then
                    DAL:AddToDKPTable(sender, classFromRaid) 
                    Core:Print("added "..sender.." successfully to dkp table.")
                    player = DAL:GetFromDKPTable(sender)
                end
            end
        end
        
        View:AddBidder(player)
    end
end

local function HandleDKPEventMessage(prefix, message, distribution, sender)
    if (sender ~= UnitName("player")) then
        local decoded = LibDeflate:DecompressDeflate(LibDeflate:DecodeForWoWAddonChannel(message))
        local success, deserialized = LibAceSerializer:Deserialize(decoded);
        if success then
            DAL:WipeAndSetNewDKPTable(deserialized.updatedTable)

            -- add event to history
            DAL:AddToHistory(deserialized.players, deserialized.dkpAdjustment, deserialized.reason)
        end
    end
end

local function HandleDataVersionSyncMessage(prefix, message, distribution, sender)
    if (sender ~= UnitName("player")) then
        Core:TryUpdateKnownVersion(message)
        local latestKnownVersion = Core:GetLatestKnownVersion();
    
        Communicator:SendCommMessage(DATA_VERSION_SYNC_RESPONSE_CHANNEL_PREFIX, latestKnownVersion, "WHISPER", sender)
    end
end

local function HandleDataVersionSyncResponseMessage(prefix, message, distribution, sender)
    Core:TryUpdateKnownVersion(message)
end

------------------------------
-- Outgoing communication below

function Core:RequestDataVersionSync(currentVersionIndex)
    Communicator:SendCommMessage(DATA_VERSION_SYNC_CHANNEL_PREFIX, currentVersionIndex, "GUILD")
end

function Core:SendDKPEventMessage(listOfAdjustedPlayers, dkpAdjustment, reason)
    local serialized = nil;
    local packet = nil;
    local unprocessedTable = {
        updatedTable = DAL:GetDKPTable(),
        players = listOfAdjustedPlayers,
        dkpAdjustment = dkpAdjustment,
        reason = reason,
    }

    if unprocessedTable then
        serialized = LibAceSerializer:Serialize(unprocessedTable);  -- serializes tables to a string
    end

    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
    if compressed then
        packet = LibDeflate:EncodeForWoWAddonChannel(compressed)
    end
    
    Communicator:SendCommMessage(DKP_EVENT_CHANNEL_PREFIX, packet, "RAID", nil, "NORMAL")
end

function Core:SubmitBid()
    Communicator:SendCommMessage(SUBMIT_BIDDING_CHANNEL_PREFIX, "nodisconnectmsg", "RAID")
end

function Core:SubmitBidPass()
    Communicator:SendCommMessage(SUBMIT_BIDDING_CHANNEL_PREFIX, passOnItemBidMessage, "RAID")
end


function Core:BroadcastThirtyDKPData()
    local serialized = nil;
    local packet = nil;
    local unprocessedTables = {
        dkpTable = DAL:GetDKPTable(),
        options = DAL:GetOptions(),
        history = DAL:GetDKPHistory(),
    }

    if unprocessedTables then
        serialized = LibAceSerializer:Serialize(unprocessedTables);  -- serializes tables to a string
    end

    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
    if compressed then
        packet = LibDeflate:EncodeForWoWAddonChannel(compressed)
    end

    Communicator:SendCommMessage(DKPTABLE_BROADCAST_CHANNEL_PREFIX, packet, "GUILD", nil, "NORMAL", ThirtyDKP_BroadcastingCallback, nil)
end

function Core:Announce(message)
    Communicator:SendCommMessage(PRINT_MSG_CHANNEL_PREFIX, message, "RAID");
end

function Core:StartBidding(item, timer)
    if IsInRaid() then
        biddingInProgress = true
        local startBiddingMessage = tostring(timer).."-"..tostring(item)
        Communicator:SendCommMessage(START_BIDDING_CHANNEL_PREFIX, startBiddingMessage, "RAID")

        local secondsLeft = timer
        local bidTimer = C_Timer.NewTicker(1, function() 
            if (secondsLeft % 10 == 0) or secondsLeft < 6 then
                Communicator:SendCommMessage(PRINT_MSG_CHANNEL_PREFIX, "Seconds left to bid: "..tostring(secondsLeft), "RAID");
            end
            secondsLeft = secondsLeft-1
            if secondsLeft == 0 then
                biddingInProgress = false
                Communicator:SendCommMessage(PRINT_MSG_CHANNEL_PREFIX, "Bidding closed for: "..tostring(item), "RAID");
                View:HideBiddingFrame()
            end
        end, timer)
    else
        Core:Print("You need to be in a raid to start bidding.")
    end
end


-------------------------------------------------
-- Message Controller
-------------------------------------------------
function Communicator:OnCommReceived(prefix, message, distribution, sender)
    if prefix == DKPTABLE_BROADCAST_CHANNEL_PREFIX then
        HandleDKPTableBroadcastMessage(prefix, message, distribution, sender)

    elseif prefix == START_BIDDING_CHANNEL_PREFIX then
        HandleStartBiddingMessage(prefix, message, distribution, sender)

    elseif prefix == PRINT_MSG_CHANNEL_PREFIX then
        HandlePrintMsgMessage(prefix, message, distribution, sender)
    
    elseif prefix == SUBMIT_BIDDING_CHANNEL_PREFIX then
        HandleSubmitBidMessage(prefix, message, distribution, sender)

    elseif prefix == DKP_EVENT_CHANNEL_PREFIX then
        HandleDKPEventMessage(prefix, message, distribution, sender)

    elseif prefix == DATA_VERSION_SYNC_CHANNEL_PREFIX then
        HandleDataVersionSyncMessage(prefix, message, distribution, sender)

    elseif prefix == DATA_VERSION_SYNC_RESPONSE_CHANNEL_PREFIX then
        HandleDataVersionSyncResponseMessage(prefix, message, distribution, sender)

    end
end

-------------------------------------------------
-- Register Broadcasting "Channels"
-------------------------------------------------
function Core:InitializeComms()
    if not Communicator then Communicator = LibStub("AceAddon-3.0"):NewAddon("ThirtyDKP", "AceComm-3.0") end;

    Communicator:RegisterComm(DKPTABLE_BROADCAST_CHANNEL_PREFIX, Communicator:OnCommReceived());
    Communicator:RegisterComm(START_BIDDING_CHANNEL_PREFIX, Communicator:OnCommReceived());
    Communicator:RegisterComm(PRINT_MSG_CHANNEL_PREFIX, Communicator:OnCommReceived());
    Communicator:RegisterComm(SUBMIT_BIDDING_CHANNEL_PREFIX, Communicator:OnCommReceived());
    Communicator:RegisterComm(DKP_EVENT_CHANNEL_PREFIX, Communicator:OnCommReceived());
    Communicator:RegisterComm(DATA_VERSION_SYNC_CHANNEL_PREFIX, Communicator:OnCommReceived());
    Communicator:RegisterComm(DATA_VERSION_SYNC_RESPONSE_CHANNEL_PREFIX, Communicator:OnCommReceived());

end