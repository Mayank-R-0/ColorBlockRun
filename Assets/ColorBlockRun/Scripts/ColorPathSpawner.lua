local c = require("Constants")
local gameManagerModule = require("GameManager")
local colorBlockComponents : ColorBlock = {}
local mainUI = nil
--!SerializeField
local barrier : GameObject = nil

local barrierHitRequest = Event.new("BarrierHitRequest")
local barrierHitEvent = Event.new("BarrierHitEvent")

function FillChildComponents()
    for i = 0, self.transform.childCount - 1, 1 do
        table.insert(colorBlockComponents, self.transform:GetChild(i):GetComponent("ColorBlock"))
    end
end

function SetOtherBlocksState(blockColor, isEnable)
    for colorBlockIndex in colorBlockComponents do
        if(colorBlockComponents[colorBlockIndex].colorKey ~= blockColor) then
            colorBlockComponents[colorBlockIndex].gameObject:SetActive(isEnable)
        end 
    end

    if(not isEnable) then
        if (blockColor == gameManagerModule.currentPlayerColor) then
            return
        else
            print("reposition player to start")
            --gameManagerModule.clientEventRequest:FireClient(gameManagerModule.clientEventRequest, "RepositionToStart")
        end
    end
end

function UpdateColors(dataString)
    local substrings = {}
    for substring in dataString:gmatch("[^,]+") do
        table.insert(substrings, substring)
    end

    for i = 1, 100, 1 do
        colorBlockComponents[i].UpdateColor(substrings[i])
    end
end

function playerCollision(other : Collider)
    print("Collided Player is : ", other.gameObject.name)
end

function self:ClientAwake()
   FillChildComponents()

   gameManagerModule.clientJoinRequest:FireServer()
   --mainUI = self:GetComponent("MainUI")
   --mainUI.setRoundText("Hello Print")
--    barrier:GetComponent("Barrier").barrierTriggerRequest:Connect(function(...)
--     print("event Recieved")
--         playerCollision(...)
--    end)

    --barrier.gameObject:SetActive(false)


end