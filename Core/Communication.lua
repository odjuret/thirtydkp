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

local biddingInProgress = false

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

local function HandleStartBiddingMessage(prefix, message, distribution, sender)
    View:CreateBiddingFrame(message);
    Core:Print("Bidding started for: "..message.."") 
    -- todo: include timer in message
    C_Timer.After(15, function()
        View:HideBiddingFrame()
    end)   
end

local function HandlePrintMsgMessage(prefix, message, distribution, sender)
    Core:Print(""..message.."") 
end

local function HandleSubmitBidMessage(prefix, message, distribution, sender)
    if biddingInProgress then
        Core:Print("Incoming bid from "..sender.."") 
        local player = DAL:GetFromDKPTable(sender)

        if player == false then
            local nameFromRaid, classFromRaid;

            -- for every person in the raid
            for i=1, GetNumGroupMembers() do
                nameFromRaid, _, _, _, classFromRaid = GetRaidRosterInfo(i)
                
                if nameFromRaid == sender then
                    if DAL:AddToDKPTable(sender, classFromRaid) then
                        Core:Print("added "..sender.." successfully to dkp table.")
                        player = DAL:GetFromDKPTable(sender)
                    else
                        Core:Print("could not add "..sender.." to dkp table...")
                        return
                    end
                end
            end
        end
        
        View:AddBidder(player)
    end
end

function Core:SubmitBid()
    Communicator:SendCommMessage(SUBMIT_BIDDING_CHANNEL_PREFIX, "amessagejusttokeepfromdisconnecting", "RAID")
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

function Core:Announce(message)
    Communicator:SendCommMessage(PRINT_MSG_CHANNEL_PREFIX, message, "RAID");
end


function Core:StartBidding(item, timer)
    if IsInRaid() then
        biddingInProgress = true
        Communicator:SendCommMessage(START_BIDDING_CHANNEL_PREFIX, tostring(item), "RAID")

        local secondsLeft = timer
        local bidTimer = C_Timer.NewTicker(1, function() 
            if (secondsLeft % 5 == 0) or secondsLeft < 6 then
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
    -- todo: switch case
    if prefix == DKPTABLE_BROADCAST_CHANNEL_PREFIX then
        HandleDKPTableBroadcastMessage(prefix, message, distribution, sender)

    elseif prefix == START_BIDDING_CHANNEL_PREFIX then
        HandleStartBiddingMessage(prefix, message, distribution, sender)

    elseif prefix == PRINT_MSG_CHANNEL_PREFIX then
        HandlePrintMsgMessage(prefix, message, distribution, sender)
    
    elseif prefix == SUBMIT_BIDDING_CHANNEL_PREFIX then
        HandleSubmitBidMessage(prefix, message, distribution, sender)
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

end