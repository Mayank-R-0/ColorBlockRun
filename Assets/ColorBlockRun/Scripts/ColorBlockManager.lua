local utilsScript = require("Utils")

local childComponents = {}

local currentBlockSelected = 0

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
end

function initializeChildComponents()
    for i = 0, self.transform.childCount - 1, 1 do
        table.insert(childComponents, self.transform:GetChild(i):GetComponent("ColorBlock"))
    end
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