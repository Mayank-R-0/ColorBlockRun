local utilsScript = require("Utils")

local childComponents = {}

local currentBlockSelected = 0

--!SerializeField
local confetti1 : GameObject = nil
--!SerializeField
local confetti2 : GameObject = nil
--!SerializeField
local confetti3 : GameObject = nil
--!SerializeField
local confetti4 : GameObject = nil
--!SerializeField
local confetti5 : GameObject = nil

updatePlayerColorEvent = Event.new("updatePlayerColor")
gameEndReachedEvent = Event.new("gameEndReached")

function updatePlayerColor(colorKey, blockIndex)    
    currentBlockSelected = blockIndex
    updatePlayerColorEvent.FireClient(updatePlayerColorEvent, colorKey)
    --print("Current Index on which color we are is : ", blockIndex)
end

function enableColorBlockBlockers(enable)
    childComponents[currentBlockSelected].SetBlockersState(enable)
end

function gameEndReached()
    print("Game End Reached at colorBlockManager")
    gameEndReachedEvent.FireClient(gameEndReachedEvent)

    confetti1:GetComponent(ParticleSystem):Play(true)
    confetti2:GetComponent(ParticleSystem):Play(true)
    Timer.After(1, function()        
        confetti3:GetComponent(ParticleSystem):Play(true)
        confetti4:GetComponent(ParticleSystem):Play(true)
        confetti5:GetComponent(ParticleSystem):Play(true)
        Timer.After(5, function()            
            confetti3:GetComponent(ParticleSystem):Stop(true)
            confetti4:GetComponent(ParticleSystem):Stop(true)
            confetti5:GetComponent(ParticleSystem):Stop(true)
        end)
    end)
end

function initializeChildComponents()
    for i = 0, self.transform.childCount - 1, 1 do
        table.insert(childComponents, self.transform:GetChild(i):GetComponent("ColorBlock"))
    end

    confetti3:GetComponent(ParticleSystem):Stop(true)
    confetti4:GetComponent(ParticleSystem):Stop(true)
    confetti5:GetComponent(ParticleSystem):Stop(true)

end

function UpdateGamePathColors(colorData)
    local colorValues = utilsScript.splitRandomNumbersString(colorData)

    for i = 1, utilsScript.NumberOfColorBlocks, 1 do
        childComponents[i].UpdateBlockColor(colorValues[i], i)
    end
end

function ApplyBlockStates(currentColor, roundState)
    if not roundState then
        for colorBlockIndex in childComponents do
            if(childComponents[colorBlockIndex].colorKey ~= currentColor) then
                childComponents[colorBlockIndex].gameObject:SetActive(false)
            end 
        end        
        if currentBlockSelected ~= 0 then
            enableColorBlockBlockers(true)
        end
    else
        for colorBlockIndex in childComponents do
            childComponents[colorBlockIndex].gameObject:SetActive(true)
        end
        if currentBlockSelected ~= 0 then
            enableColorBlockBlockers(false)
        end
    end
end

function self:ClientAwake()
    initializeChildComponents()
end