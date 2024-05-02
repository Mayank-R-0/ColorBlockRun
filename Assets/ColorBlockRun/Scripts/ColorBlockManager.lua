local utilsScript = require("Utils")

local childComponents = {}

updatePlayerColorEvent = Event.new("updatePlayerColor")
gameEndReachedEvent = Event.new("gameEndReached")

function updatePlayerColor(colorKey)    
    updatePlayerColorEvent.FireClient(updatePlayerColorEvent, colorKey)
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

    for i = 1, 100, 1 do
        childComponents[i].UpdateBlockColor(colorValues[i])
    end
end

function ApplyBlockStates(currentColor, roundState)
    if not roundState then
        for colorBlockIndex in childComponents do
            if(childComponents[colorBlockIndex].colorKey ~= currentColor) then
                childComponents[colorBlockIndex].gameObject:SetActive(false)
            end 
        end
    else
        for colorBlockIndex in childComponents do
            childComponents[colorBlockIndex].gameObject:SetActive(true)
        end
    end
end

function self:ClientAwake()
    initializeChildComponents()
end