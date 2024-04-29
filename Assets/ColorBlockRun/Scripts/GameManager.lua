--[[

    Variable Declarations

]]

local c = require("Constants")

local minimumPlayerToStartGame = 1
local gameStarted : boolean = false



local numberOfRounds = 15
local roundTime = 5
local waitTime = 10
local playerLobbyTimer

local gameTimer = nil 

local currentColor : number = 1
local currentRound = 1
local roundState : boolean = false
local gameplayRoundClosed : boolean = false

gameSetupEvent = Event.new("GameSetupEvent")
roundEvent = Event.new("RoundEvent")

local blockColors = {}
local currentColorString = "" 
--[[

    Player Manager Start

]]

players = {}
local mt_players = {
    __len = function(tbl)
        local count = 0
        for _ in pairs(tbl) do
            count += 1
        end
        return count
    end
}
setmetatable(players, mt_players)

clientJoinRequest = Event.new("ClientJoinRequest")

local function TrackPlayers(game, characterCallback)
    scene.PlayerJoined:Connect(function(scene, player)
        players[player] = {
            player = player,
            playerId = player.id
        }


        player.CharacterChanged:Connect(function(player, character)
            local playerinfo = players[player]
            if(character == nil) then
                return
            end

            if characterCallback then 
                characterCallback(playerinfo)
            end
        end)

        if(not gameStarted and #players >= minimumPlayerToStartGame) then
            print("Call To start the game")
            StartGame()
        end
    end)

    scene.PlayerLeft:Connect(function(player)
        players[player] = nil

        if(gameStarted) then 
            EndGame()
        end

    end)

end

--[[

    Player Manager End

]]


--[[

    Gameplay Manager Start

]]


--[[

    Gameplay Manager End

]]




--[[

    Function Declarations

]]

function ApplyGameState()
    print("ApplyGameState called")
    roundEvent:FireAllClients(tostring(currentColor), roundState)    
    if(roundState) then
        --print("Calling random color assignment")
        currentRound += 1
        print("Current Round: ", currentRound)
        AssignRandomColor()
    end
    roundState = not roundState 
end

function StartGame()
    print("StartGame")
    gameStarted = true
    CreateBlockColors()
    AssignRandomColor()  
    print("Waiting for Players..!") 
    playerLobbyTimer = Timer.After(waitTime, function() CloseRoomAndStartGame() end) 
    -- playerLobbyTimer:Start()
end

function EndGame()
    if #players <= 0 then 
        gameStarted = false
    end
end

function GiveRewards()
    print("Giving Rewards")
    
    gameStarted  = false
    gameplayRoundClosed = false
end

function CloseRoomAndStartGame()
    print("Waiting Period Over..! Starting Game")
    gameplayRoundClosed = true
    gameTimer = Timer.Every(roundTime, function() 
        CheckForLastRound()
    end)
    --gameTimer:Start()
end

function CheckForLastRound()
    if (currentRound >= numberOfRounds) then
        gameTimer.Stop()
        GiveRewards()
    else 
        ApplyGameState()
    end
end


function AssignRandomColor()
    local rand = c.randomBetween()
    print("random number is ", rand)
    currentColor = rand
end


function CreateBlockColors()
    for i = 1, 100, 1 do
        blockColors[i] = c.randomBetween()
    end
    CreateCurrentColorString()
end

function CreateCurrentColorString()
    local valueString = ""
    for i = 1, 100, 1 do
        valueString = valueString .. tostring(blockColors[i]) .. ","
    end
    currentColorString = valueString
    
    gameSetupEvent:FireAllClients(currentColorString)
end


function self:ServerAwake()
    TrackPlayers()

    clientJoinRequest:Connect(function(player, arg)
        print("Client Request recieved")
        gameSetupEvent:FireAllClients(currentColorString)
    end)
end

function self:ServerUpdate()

end