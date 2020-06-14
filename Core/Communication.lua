local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL

local Communicator = LibStub("AceAddon-3.0"):NewAddon("ThirtyDKP", "AceComm-3.0")

local LibAceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibDeflate = LibStub:GetLibrary("LibDeflate")

-- Channel prefixes have a max length of 16 character
local DKPTABLE_BROADCAST_CHANNEL_PREFIX = "TDKPBroadcast";


local function HandleDKPTableBroadcastMessage(prefix, message, distribution, sender)
    Core:Print("HandleDKPTableBroadcastMessage recieved: message: "..tostring(message)..". sender: "..tostring(sender))
end

function Core:BroadcastDKPTable()
    Communicator:SendCommMessage(DKPTABLE_BROADCAST_CHANNEL_PREFIX, "test data being transmitted", "GUILD")
end

-------------------------------------------------
-- Message Controller
-------------------------------------------------
function Communicator:OnCommReceived(prefix, message, distribution, sender)
    if prefix == DKPTABLE_BROADCAST_CHANNEL_PREFIX then
        HandleDKPTableBroadcastMessage(prefix, message, distribution, sender)
    end
    
end

-------------------------------------------------
-- Register Broadcasting "Channels"
-------------------------------------------------
function Core:InitializeComms()
    if not Communicator then Communicator = LibStub("AceAddon-3.0"):NewAddon("ThirtyDKP", "AceComm-3.0") end;

    Communicator:RegisterComm(DKPTABLE_BROADCAST_CHANNEL_PREFIX, Communicator:OnCommReceived())
end