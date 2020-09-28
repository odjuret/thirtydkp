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
local REVERT_DKP_EVENT_CHANNEL_PREFIX = "TDKPRevEvent";
local DATA_VERSION_SYNC_CHANNEL_PREFIX = "TDKPDataSync";
local DATA_VERSION_SYNC_RESPONSE_CHANNEL_PREFIX = "TDKPDataSyncRe";


-------------------------
-- incoming communication

local function HandleDKPTableBroadcastMessage(prefix, message, distribution, sender)
    if (sender ~= UnitName("player")) then
        local decoded = LibDeflate:DecompressDeflate(LibDeflate:DecodeForWoWAddonChannel(message))
        local success, deserialized = LibAceSerializer:Deserialize(decoded);
        if success then
            StaticPopupDialogs["TDKP_FULL_BROADCAST_WARNING"] = {
                text = "Warning! Incoming DKP Table broadcast. Do you trust the sender "..sender.."?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    DAL:WipeAndSetNewDKPTable(deserialized.dkpTable)
                    DAL:WipeAndSetNewOptions(deserialized.options)
                    DAL:WipeAndSetNewHistory(deserialized.history)
                    StaticPopup_Hide ("TDKP_FULL_BROADCAST_WARNING")
                    View:UpdateAllViews();
                    Core:CheckDataVersion(0);
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show ("TDKP_FULL_BROADCAST_WARNING")
        else
            Core:Print("DKP Table broadcasting message recieved but something went wrong... Contact Authors.")
        end
    end
end

local function HandleStartBiddingMessage(prefix, message, distribution, sender)
    Core:IncomingStartBiddingHandler(message)  
end

local function HandlePrintMsgMessage(prefix, message, distribution, sender)
    Core:Print(""..message.."") 
end

local function HandleSubmitBidMessage(prefix, message, distribution, sender)
    Core:IncomingBidsHandler(message, sender)
end

local function HandleDKPEventMessage(prefix, message, distribution, sender)
    if (sender ~= UnitName("player")) then
        local decoded = LibDeflate:DecompressDeflate(LibDeflate:DecodeForWoWAddonChannel(message))
        local success, deserialized = LibAceSerializer:Deserialize(decoded);
        if success then
            if not Core:DoesDataBelongToSameGuild(deserialized.updatedTable.version) then
                -- todo: turn off events for this raid
                Core:Print("Incoming DKP events from different guild.")
                Core:Print("Request a broadcast from admin to remove these messages.")
                return;
            end

            -- always use latest incoming dkp table
            DAL:WipeAndSetNewDKPTable(deserialized.updatedTable)

            -- if data versions mismatch, local data is outdated
            if Core:CheckHistoryDataVersion(deserialized.previousHistoryVersion) then
                DAL:AddEntryToHistory(deserialized.historyEntry)
                DAL:UpdateDKPHistoryVersion(deserialized.newHistoryVersion)
            end
            View:UpdateAllViews();
        end
    end
end

local function HandleRevertDKPEventMessage(prefix, message, distribution, sender)
    if (sender ~= UnitName("player")) then
        local decoded = LibDeflate:DecompressDeflate(LibDeflate:DecodeForWoWAddonChannel(message))
        local success, deserialized = LibAceSerializer:Deserialize(decoded);
        if success then
            if not Core:DoesDataBelongToSameGuild(deserialized.updatedTable.version) then
                -- todo: turn off events for this raid
                Core:Print("Incoming DKP events from different guild.")
                Core:Print("Request a broadcast from admin to remove these messages.")
                return;
            end

            -- always use latest incoming dkp table
            DAL:WipeAndSetNewDKPTable(deserialized.updatedTable)

            -- if data versions mismatch, local data is outdated
            if Core:CheckHistoryDataVersion(deserialized.previousHistoryVersion) then
                DAL:DeleteHistoryEntry(deserialized.historyEntry);
                DAL:UpdateDKPHistoryVersion(deserialized.newHistoryVersion)
            end
            View:UpdateAllViews();
        end
    end
end

local function HandleDataVersionSyncMessage(prefix, message, distribution, sender)
    if (sender ~= UnitName("player")) then
        Core:TryUpdateKnownVersions(message)
        local dkpTableVersion, historyVersion = Core:GetLatestKnownVersions()
    
        Communicator:SendCommMessage(DATA_VERSION_SYNC_RESPONSE_CHANNEL_PREFIX, dkpTableVersion.."/"..historyVersion, "WHISPER", sender)
    end
end

local function HandleDataVersionSyncResponseMessage(prefix, message, distribution, sender)
    Core:TryUpdateKnownVersions(message)
end

------------------------------
-- Outgoing communication below

function Core:RequestDataVersionSync(currentKnownVersions)
    Communicator:SendCommMessage(DATA_VERSION_SYNC_CHANNEL_PREFIX, currentKnownVersions, "GUILD")
end

function Core:SendDKPEventMessage(newHistoryEntry, lastHistoryVersion)
    local serialized = nil;
    local packet = nil;
    local unprocessedTable = {
        updatedTable = DAL:GetDKPTable(),
        historyEntry = newHistoryEntry,
        previousHistoryVersion = lastHistoryVersion,
        newHistoryVersion = DAL:GetDKPHistoryVersion(),
    }

    if unprocessedTable then
        serialized = LibAceSerializer:Serialize(unprocessedTable);  -- serializes tables to a string
    end

    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
    if compressed then
        packet = LibDeflate:EncodeForWoWAddonChannel(compressed)
    end
    
    Communicator:SendCommMessage(DKP_EVENT_CHANNEL_PREFIX, packet, "GUILD", nil, "NORMAL")
end

function Core:SendRevertDKPEventMessage(deletedHistoryEntry, lastHistoryVersion)
    local serialized = nil;
    local packet = nil;
    local unprocessedTable = {
        updatedTable = DAL:GetDKPTable(),
        historyEntry = deletedHistoryEntry,
        previousHistoryVersion = lastHistoryVersion,
        newHistoryVersion = DAL:GetDKPHistoryVersion(),
    }

    if unprocessedTable then
        serialized = LibAceSerializer:Serialize(unprocessedTable);  -- serializes tables to a string
    end

    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
    if compressed then
        packet = LibDeflate:EncodeForWoWAddonChannel(compressed)
    end
    
    Communicator:SendCommMessage(REVERT_DKP_EVENT_CHANNEL_PREFIX, packet, "GUILD", nil, "NORMAL")
end

function Core:CommunicateSubmitBids(submitBidsMessage)
    Communicator:SendCommMessage(SUBMIT_BIDDING_CHANNEL_PREFIX, submitBidsMessage, "RAID")
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

function Core:RaidAnnounce(message)
    Communicator:SendCommMessage(PRINT_MSG_CHANNEL_PREFIX, message, "RAID");
end

function Core:CommunicateBidding(startBiddingMessage)
    Communicator:SendCommMessage(START_BIDDING_CHANNEL_PREFIX, startBiddingMessage, "RAID")
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

    elseif prefix == REVERT_DKP_EVENT_CHANNEL_PREFIX then
        HandleRevertDKPEventMessage(prefix, message, distribution, sender)

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
    Communicator:RegisterComm(REVERT_DKP_EVENT_CHANNEL_PREFIX, Communicator:OnCommReceived());
    Communicator:RegisterComm(DATA_VERSION_SYNC_CHANNEL_PREFIX, Communicator:OnCommReceived());
    Communicator:RegisterComm(DATA_VERSION_SYNC_RESPONSE_CHANNEL_PREFIX, Communicator:OnCommReceived());

end
