local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View

local Communicator = LibStub("AceAddon-3.0"):NewAddon("ThirtyDKP", "AceComm-3.0")

local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

-- Channel prefixes have a max length of 16 character
local DKPTABLE_BROADCAST_CHANNEL_PREFIX = "TDKPBroadcast";


-------------------------------------------------
-- Callback used by communicator when transmitting 
-- TODO: Move this into View/BroadcastStatusFrame.lua and use it to display progress
-------------------------------------------------
local bytesSent = 0
local bytesTotal = 0

function BroadcastingCallback(arg1, arg2, arg3)
	bytesSent = arg2
	bytesTotal = arg3

	if arg2 == arg3 then
		bytesSent = 0
		bytesTotal = 0
	end
end

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
                    DAL:WipeAndSetNewDKPTable(deserialized)
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

function Core:BroadcastDKPTable()
    local serialized = nil;
    local packet = nil;
    local tempTable = DAL:GetDKPTable()

    if tempTable then
        serialized = LibAceSerializer:Serialize(tempTable);  -- serializes tables to a string
    end

    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
    if compressed then
        packet = LibDeflate:EncodeForWoWAddonChannel(compressed)
    end

    Communicator:SendCommMessage(DKPTABLE_BROADCAST_CHANNEL_PREFIX, packet, "GUILD", nil, "NORMAL", BroadcastingCallback, nil)
end

-------------------------------------------------
-- Message Controller
-------------------------------------------------
function Communicator:OnCommReceived(prefix, message, distribution, sender)
    if prefix == DKPTABLE_BROADCAST_CHANNEL_PREFIX then
        HandleDKPTableBroadcastMessage(prefix, message, distribution, sender)
    end
    -- TODO: delegate all other messages by prefix here
end

-------------------------------------------------
-- Register Broadcasting "Channels"
-------------------------------------------------
function Core:InitializeComms()
    if not Communicator then Communicator = LibStub("AceAddon-3.0"):NewAddon("ThirtyDKP", "AceComm-3.0") end;

    Communicator:RegisterComm(DKPTABLE_BROADCAST_CHANNEL_PREFIX, Communicator:OnCommReceived())
end