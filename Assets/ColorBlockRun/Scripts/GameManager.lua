local c = require("Constants")
--!SerializeField
local numberOfRounds : number = 15
--!SerializeField
local roundTime : number = 5
local gameTimer

local currentColor : number = 1
local currentRound : number = 1
local roundState : boolean = false

roundEvent = Event.new("RoundEvent")



function ApplyGameState()
    print("ApplyGameState called")
    roundEvent:FireAllClients(tostring(currentColor), roundState)    
    if(roundState) then
        print("Calling random color assignment")
        AssignRandomColor()
    end
    roundState = not roundState 
end

function StartGame()
    print("StartGame")
    AssignRandomColor()
    gameTimer = Timer.new(roundTime, function() ApplyGameState() end, true)
    gameTimer:Start()
end

function AssignRandomColor()
    local rand = c.randomBetween()
    print("random number is ", rand)
    currentColor = rand
end

function self:ServerAwake()
    local gameTimerNew = Timer.new(2, function() StartGame() end, false)
end