--[[
    Handling All color blocks in the scene
]]

local utilsScript = require("Utils")              -- reference to utils script

local childComponents = {}                        -- container include all the color blocks that are child of this gameobject

local currentBlockSelected = 0                    -- Current block index on which player is standing 
local gameEnded = false                           -- whether game is ended or not
local waitingForGameToEnd = false                 -- state to store if the player joined in between of game running

--!SerializeField
local startLine : GameObject = nil                -- reference to start line
--!SerializeField
local endLine : GameObject = nil                  -- reference to end line

--!SerializeField
local confetti1 : GameObject = nil                -- Confetti on the left side of finish line
--!SerializeField
local confetti2 : GameObject = nil                -- Confetti on the right side of finish line
--!SerializeField
local confetti3 : GameObject = nil                -- Confetti on the left trophy
--!SerializeField
local confetti4 : GameObject = nil                -- Confetti on the right trophy
--!SerializeField
local confetti5 : GameObject = nil                -- Confetti on the center trophy

--!SerializeField
local gameManagerReference : GameObject = nil

updatePlayerColorEvent = Event.new("updatePlayerColor")            -- Event send to gameplay manager when player changes the color block
gameEndReachedEvent = Event.new("gameEndReached")                  -- Event send to gameplay manager when player reaches game end

-- Function updates the block index and fires the event to gameplay manager to update color block on which player is currently standing
function updatePlayerColor(colorKey, blockIndex, isDisabled)
    if(not isDisabled) then     
        currentBlockSelected = blockIndex
    end
    gameManagerReference:GetComponent("GameplayManager").serverUpdateColorRequest:FireServer(colorKey, isDisabled)
    --print("Current Index on which color we are is : ", blockIndex)
end

-- Handles the blockers state of current block on which player is standing when the blocks gets to invisible state
function enableColorBlockBlockers(enable)
    if(currentBlockSelected ~= "" or currentBlockSelected ~= nil) then
        childComponents[currentBlockSelected].SetBlockersState(enable)
    end
end

-- Handles game end reached, Fires event to gameplay manager and enables the confetti, disables clicks to the color blocks
function gameEndReached()
    --print("Game End Reached at colorBlockManager")
    gameEnded = true
    gameManagerReference:GetComponent("GameplayManager").serverGameEndRequest:FireServer()

    UpdateLayerToTappable(false)

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

-- Storing references to the all the color blocks in the path
function initializeChildComponents()
    for i = 0, self.transform.childCount - 1, 1 do
        table.insert(childComponents, self.transform:GetChild(i):GetComponent("ColorBlock"))
    end

    confetti3:GetComponent(ParticleSystem):Stop(true)
    confetti4:GetComponent(ParticleSystem):Stop(true)
    confetti5:GetComponent(ParticleSystem):Stop(true)
end

-- Updates the colors of blocks on the path once at the game start
function UpdateGamePathColors(colorData)
    local colorValues = utilsScript.splitRandomNumbersString(colorData)
    local LayerIgnoreRaycast = LayerMask.NameToLayer("Ignore Raycast");
    for i = 1, utilsScript.NumberOfColorBlocks, 1 do
        childComponents[i].UpdateBlockColor(colorValues[i], i)
    end
    UpdateLayerToTappable(false)
    gameEnded = false
end

-- Apply the enable/disable state to the color blocks according to round state
function ApplyBlockStates(currentColor, roundState)
    if not roundState then
        for colorBlockIndex in childComponents do
            if(childComponents[colorBlockIndex].colorKey ~= currentColor) then
                childComponents[colorBlockIndex].SetBlockState(false)
            end 
        end        
        if currentBlockSelected ~= 0 then
            enableColorBlockBlockers(true)
        end
    else
        for colorBlockIndex in childComponents do
            childComponents[colorBlockIndex].SetBlockState(true)
        end
        if currentBlockSelected ~= 0 then
            enableColorBlockBlockers(false)
        end
    end
    if not gameEnded then
        if not waitingForGameToEnd then
            UpdateLayerToTappable(roundState)
        end
    end
end

-- Client Awake to store all the color block references
function self:ClientAwake()
    initializeChildComponents()
end

-- Handles weather color block can be tappable or not, usually needs when we want to stop the player moving while the game is not started or blocks are invisible
function UpdateLayerToTappable(isTappable)
    if isTappable then
        local triggerLayer = LayerMask.NameToLayer("CharacterTrigger")
        local defaultLayer = LayerMask.NameToLayer("Default")
        startLine.layer = defaultLayer
        endLine.layer = defaultLayer
        for colorBlockIndex in childComponents do
            childComponents[colorBlockIndex].gameObject.layer = triggerLayer
            childComponents[colorBlockIndex].transform:GetChild(0).gameObject.layer = defaultLayer
        end
    else
        local ignoreLayer = LayerMask.NameToLayer("Ignore Raycast")
        startLine.layer = ignoreLayer
        endLine.layer = ignoreLayer
        for colorBlockIndex in childComponents do
            childComponents[colorBlockIndex].gameObject.layer = ignoreLayer
            childComponents[colorBlockIndex].transform:GetChild(0).gameObject.layer = ignoreLayer
        end
    end

end

-- Updates the wait game status when players joins lait or after the game has been started
function UpdateWaitGameStatus(shouldWaitForGameEnd)
    waitingForGameToEnd = shouldWaitForGameEnd
end