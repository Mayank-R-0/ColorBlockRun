local utilsScript = require("Utils")

--!SerializeField
local colorBlockManager : GameObject = nil
--!SerializeField
local startBarrier : GameObject = nil
--!SerializeField
local endBarrier : GameObject = nil
--!SerializeField
local respawnPoint : GameObject = nil
--!SerializeField
local uiManager : GameObject = nil
--!SerializeField
local cameraObject : GameObject = nil
--!SerializeField
local deathSound : AudioSource = nil
local mainUI = nil


local colorString = ""
function generatePathColorsForCurrentGame()
    colorString = utilsScript.getRandomNumbersAsString(utilsScript.NumberOfColorBlocks)
end

local lobbyTimer = nil
local lobbyTime = 10
local gameTimer = nil
local roundTime = 5
local minimumNumberOfPlayers = 1

local currentColor = ""
local currentRound = 0
local maxRounds = 15
local waitingForPlayer = false
local gameStarted = false
local roundState = false
local raceWon = false

local currentPlayerColor = ""

local clientConnectionRequest = Event.new("ClientConnectionRequest")
local clientDataRecieveEvent = Event.new("ClientDataRecieveEvent")

local serverGameStartEvent = Event.new("ServerGameStartEvent")
local serverRoundChangeEvent = Event.new("ServerRoundChangeEvent")

local playerTeleportationRequest = Event.new("PlayerTeleportationRequest")
local playerTeleportationEvent = Event.new("PlayerTeleportationEvent")

local gameEndReachedAtClientRequest = Event.new("GameEndReachedAtClientRequest")
local serverGameTimerSyncEvent = Event.new("ServerGameTimerSyncEvent")
local restartGameEvent = Event.new("RestartGameEvent")
local waitingForPlayersEvent = Event.new("WaitingForPlayersEvent")

local startClientTimer = false
local currentClientTime = 10
local showInMessageBox = false
local startPosition = nil


function setStartBarrierState(state)
    startBarrier.SetActive(startBarrier, state)
end

function setEndBarrierState(state)
    endBarrier.SetActive(endBarrier, state)
end

local winPlayers = {}
local mt_winPlayers = {
    __len = function(tbl)
        local count = 0
        for _ in pairs(tbl) do
            count += 1
        end
        return count
    end
}
setmetatable(winPlayers, mt_winPlayers)

local players = {}
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

        if(#players >= minimumNumberOfPlayers) then
            if(not waitingForPlayer) then
                if (not gameStarted) then
                    StartWaitingForPlayer()
                end
            end
        end
    end)

    scene.PlayerLeft:Connect(function(player)
        players[player] = nil

        if(#players < minimumNumberOfPlayers) then
            endGame()
        end

    end)

end


function endGame()
    print("Ending Game")
    restartGameEvent:FireAllClients(restartGameEvent)

    --print("Current paths on server are : ", colorString)
    generatePathColorsForCurrentGame()
    Timer.After(3, function()  
        currentColor = ""
        currentRound = 0
        roundState = false
        waitingForPlayer = false
        gameStarted = false

        waitingForPlayersEvent:FireAllClients(waitingForPlayersEvent, colorString)
        StartWaitingForPlayer()
    end)
end


function StartWaitingForPlayer()
    print("Waiting for Players")

    waitingForPlayer = true
    lobbyTimer = Timer.After(lobbyTime, function() 
        StartGameplayRounds()    
    end)
end

function StartGameplayRounds()
    gameStarted = true

    print("Waiting for player is over.. ! Starting game")


    ApplyRandomColorToRound()
    currentRound += 1
    serverGameStartEvent.FireAllClients(serverGameStartEvent, currentRound, currentColor)

    gameTimer = Timer.After(roundTime, function()
        ApplyRoundState()
    end)
end

function ApplyRandomColorToRound()
    currentColor = tostring(utilsScript.getRandom())
end

function ApplyRoundState()
    if(roundState == true) then
        ApplyRandomColorToRound()
        currentRound += 1
        print("Current Round : ", currentRound )
    end
    if(currentRound > maxRounds) then 
        endGame()
        return
    end
    serverRoundChangeEvent.FireAllClients(serverRoundChangeEvent, currentColor, roundState, currentRound)

    roundState = not roundState

    Timer.After(roundTime, function() 
        ApplyRoundState()
    end)
end



function BindClientEventsToServer()
    clientConnectionRequest:Connect(function(player, args)
        print("client connected : ", player.name)
        clientDataRecieveEvent.FireAllClients(clientDataRecieveEvent, player, currentRound, currentColor, colorString, gameStarted, waitingForPlayer)
    end)

    playerTeleportationRequest:Connect(function(player, position)
        print("respawn position is : ", position)
        player.character.transform.position = position
        playerTeleportationEvent:FireAllClients(player)
    end)

    gameEndReachedAtClientRequest:Connect(function(player)
        print("Player End Reached At Server.. ! Adding to winner list : ", player.name)

        winPlayers[player] = {
            player = player,
            playerId = player.id
        }

       -- table.insert(mt_winPlayers, player)
        print("players reached end .. ! : ", #winPlayers)

    end)
end

function self:ClientAwake()

    mainUI = uiManager:GetComponent("MainUI")
    startPosition = Camera.main.transform.position

    clientDataRecieveEvent:Connect(function(player, currentRoundOnServer, currentColorOnServer, colorblocksString, gameStarted, waitingForPlayer)
        if(player ~= client.localPlayer) then return end

        mainUI.setRoundText("ROUND " .. tostring(currentRoundOnServer) .. "/15")
        mainUI.updateRoundColor(currentColorOnServer)
        colorBlockManager:GetComponent("ColorBlockManager").UpdateGamePathColors(colorblocksString)
        if(gameStarted == true) then
            mainUI.setMessageText("Wait fot the next race")
            startClientTimerWithTime(5, false)
        elseif(waitingForPlayer) then
            mainUI.setMessageText("Waiting For Players")
            startClientTimerWithTime(10, false)
        end
        mainUI:enableInstructions()
    end)
    serverGameStartEvent:Connect(function(currentRoundOnServer, currentColorOnServer)
        setStartBarrierState(false)
        setEndBarrierState(false)
        mainUI.setRoundText("ROUND " .. tostring(currentRoundOnServer) .. "/15")
        mainUI.updateRoundColor(currentColorOnServer)
        mainUI.hideMessageBox()
        startClientTimerWithTime(5, false)
    end)

    serverRoundChangeEvent:Connect(function(currentColor, roundState, currentRoundOnServer)
        --print("color", currentColor, roundState)

        if(roundState == false) then
            if(currentPlayerColor == nil or currentPlayerColor =="") then 
            
            elseif(currentPlayerColor ~= currentColor and raceWon == false) then 
                playerTeleportationRequest:FireServer(respawnPoint.transform.position)
                deathSound:Play()
            end
            mainUI.updateRoundColor("")
            startClientTimerWithTime(5, true)
        else
            mainUI.setRoundText("ROUND " .. tostring(currentRoundOnServer) .. "/15")
            mainUI.updateRoundColor(currentColor)
            startClientTimerWithTime(5, false)
            mainUI.hideMessageBox()
        end

        colorBlockManager:GetComponent("ColorBlockManager").ApplyBlockStates(currentColor, roundState)
    end)

    playerTeleportationEvent:Connect(function(player)
        player.character:Teleport(respawnPoint.transform.position)
        if(player ~= client.localPlayer) then return end
        cameraObject:GetComponent("RTSCamera").CenterOn(Vector3.new(0,0,0))
        currentPlayerColor = ""
    end)

    clientConnectionRequest.FireServer(clientConnectionRequest)

    colorBlockManager:GetComponent("ColorBlockManager").updatePlayerColorEvent:Connect(function(colorKey)
        currentPlayerColor = colorKey
    end)

    colorBlockManager:GetComponent("ColorBlockManager").gameEndReachedEvent:Connect(function()
        gameEndReachedAtClientRequest.FireServer(gameEndReachedAtClientRequest)
        showInMessageBox = false
        mainUI.setMessageText("Race Completed..!")
        raceWon = true
        currentPlayerColor = ""
        Timer.After(5, function() mainUI.setMessageText("Waiting for race to complete..!") end)
    end)

    serverGameTimerSyncEvent:Connect(function(currentTime)
        mainUI.setTimerText(tostring(currentTime))
    end)

    restartGameEvent:Connect(function()
        restartGameAtClient()
    end)

    waitingForPlayersEvent:Connect(function(event, currentPathColorsOnServer)
        startClientTimerWithTime(10, false)        
        mainUI.updateRoundColor("")
        mainUI.setMessageText("Waiting For Players")
        mainUI.setRoundText("ROUND 0/15")
        --print("recieved String is : ", currentPathColorsOnServer)
        if (currentPathColorsOnServer ~= "") then            
            colorBlockManager:GetComponent("ColorBlockManager").UpdateGamePathColors(currentPathColorsOnServer)
        end
    end)

    mainUI.startLoad()
end

function self:ServerAwake()
    TrackPlayers()
    generatePathColorsForCurrentGame()
    BindClientEventsToServer()
end

function startClientTimerWithTime(recievedTime, inShowInMessageBox)
    currentClientTime = recievedTime
    startClientTimer = true
    showInMessageBox = inShowInMessageBox
end

function self:ClientUpdate()
    if(startClientTimer) then
        currentClientTime -= Time.deltaTime
        if(showInMessageBox and (not raceWon)) then
            mainUI.setMessageText("Next round in " .. tostring(math.abs(math.ceil(currentClientTime))))
        else
            mainUI.setTimerText(tostring(math.abs(math.ceil(currentClientTime))))
        end
        if(currentClientTime <= 0) then
            startClientTimer = false
        end
    end
end

function restartGameAtClient()
    colorBlockManager:GetComponent("ColorBlockManager").ApplyBlockStates("1", true)
    setStartBarrierState(true)
    setEndBarrierState(true)
    currentPlayerColor = ""
    raceWon = false
    showInMessageBox = false
    startClientTimer = false
    mainUI.setMessageText("Restarting Game .. ! Randomizing Tiles ..!")
    mainUI.setRoundText("ROUND 0/15")
    mainUI.setTimerText("0")
    playerTeleportationRequest.FireServer(playerTeleportationRequest, respawnPoint.transform.position)
end
