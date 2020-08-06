local addonName, ThirtyDKP = ... 

local Core = ThirtyDKP.Core
local DAL = ThirtyDKP.DAL
local View = ThirtyDKP.View

local biddingInProgress = false
local passOnItemBidMessage = "PassOnItemForBid"

function Core:IsBiddingInProgress()
    return biddingInProgress
end

function Core:IncomingBidsHandler(message, sender)
    if biddingInProgress then
        if message == passOnItemBidMessage then
            SendChatMessage("ThirtyDKP: "..sender.." passed. ", "RAID", nil, nil)
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
        View:UpdateAllViews()
    end
end

function Core:StartBidding(item, timer)
    if IsInRaid() then
        biddingInProgress = true
        Core:RegisterForRaidMessageEvents()
        local startBiddingMessage = tostring(timer).."-"..tostring(item)
        Core:CommunicateBidding(startBiddingMessage);

        local secondsLeft = timer
        local bidTimer = C_Timer.NewTicker(1, 
            function() 
                if (secondsLeft % 10 == 0) or secondsLeft < 6 then
                    Core:RaidAnnounce("Seconds left to bid: "..tostring(secondsLeft))
                end
                secondsLeft = secondsLeft-1
                if secondsLeft == 0 then
                    biddingInProgress = false
                    Core:UnRegisterForRaidMessageEvents()
                    Core:RaidAnnounce("Bidding closed for: "..tostring(item));
                    View:HideBiddingFrame()
                end
            end, timer)
    else
        Core:Print("You need to be in a raid to start bidding.")
    end
end

function Core:IncomingStartBiddingHandler(message)
    local timer, itemLink = strsplit("-", message);
    View:CreateBiddingFrame(itemLink);
    SendChatMessage("Bidding started for: "..itemLink.."", "RAID", nil, nil)
    C_Timer.After(timer, function()
        View:HideBiddingFrame()
    end) 
end

function Core:SubmitBid()
    Core:CommunicateSubmitBids("nodcplz")
end

function Core:SubmitBidPass()
    Core:CommunicateSubmitBids(passOnItemBidMessage)
end

function Core:HandleSubmitBidRaidMessage(text, ...)
    local name = ...;
    local message = "nodcplz";

    if string.find(name, "-") then          -- finds and removes server name from name if exists
        local dashPos = string.find(name, "-")
        name = strsub(name, 1, dashPos-1)
    end

    if string.find(text, "!pass") == 1 then
        message = passOnItemBidMessage
    end

    Core:IncomingBidsHandler(message, name)
end
