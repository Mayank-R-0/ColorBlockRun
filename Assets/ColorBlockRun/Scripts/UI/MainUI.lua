--!Type(UI)

--!Bind
local labelRound : UILabel = nil
--!Bind
local labelTimer : UILabel = nil
--!Bind
local labelMessage : UILabel = nil

function setRoundText(text)
    print("DataCollected....!")
    labelRound:SetPrelocalizedText(text,false)
end

function setTimerText(text)
    labelRound:SetPrelocalizedText(text,false)
end

function setMessageText(text)
    labelRound:SetPrelocalizedText(text,false)
end
