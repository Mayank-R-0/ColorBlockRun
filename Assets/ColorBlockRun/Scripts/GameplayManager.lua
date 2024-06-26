--[[
    Managing all the core code of client and server
]]

local utilsScript = require("Utils")
local serverStorageManager = require("ServerStorageDataManager")

--!SerializeField
local colorBlockManager : GameObject = nil
--!SerializeField
local respawnPoint : GameObject = nil
--!SerializeField
local uiManager : GameObject = nil
--!SerializeField
local cameraObject : GameObject = nil
--!SerializeField
local deathSound : AudioSource = nil
--!SerializeField
local finishLine : GameObject = nil
--!SerializeField
local startLineBarrier : GameObject = nil

--!SerializeField
local lobbySpwanPoints : Transform = nil

--!SerializeField
local teleporter : GameObject = nil

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
local endTheCurrentGame = false

local currentPlayerColor = ""

local clientConnectionRequest = Event.new("ClientConnectionRequest")
local clientDataRecieveEvent = Event.new("ClientDataRecieveEvent")

local serverGameStartEvent = Event.new("ServerGameStartEvent")
local serverRoundChangeEvent = Event.new("ServerRoundChangeEvent")

local playerTeleportationRequest = Event.new("PlayerTeleportationRequest")
local playerTeleportationEvent = Event.new("PlayerTeleportationEvent")

local gameEndReachedAtClientRequest = Event.new("GameEndReachedAtClientRequest")
local playerPositionReachedEvent = Event.new("PlayerPositionReachedEvent")
local serverGameTimerSyncEvent = Event.new("ServerGameTimerSyncEvent")
local restartGameEvent = Event.new("RestartGameEvent")
local waitingForPlayersEvent = Event.new("WaitingForPlayersEvent")


serverUpdateColorRequest = Event.new("ServerUpdateColorRequest")
local serverUpdateColorEvent = Event.new("ServerUpdateColorEvent")
serverGameEndRequest = Event.new("ServerGameEndRequest")
local serverGameEndEvent = Event.new("ServerGameEndEvent")


local startClientTimer = false
local currentClientTime = 10
local showInMessageBox = false
local startPosition = nil

local allPlayers={}
local winPlayers = {}

function IsWaitingForPlayers()
    return waitingForPlayer
end

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

local currentRacePlayers = {}
local mt_currentRacePlayers = {
    __len = function(tbl)
        local count = 0
        for _ in pairs(tbl) do
            count += 1
        end
        return count
    end
}
setmetatable(currentRacePlayers, mt_currentRacePlayers)


--- Handling Teleportation
local changeTeleporterState = Event.new("changeTeleporterState")
local setTextForWaitingForRace=Event.new("setTextForWaitingForRace")
local playerTeleportatedToRace = Event.new("playerTeleportatedToRace")

function ChangeTeleportedState(state)
    teleporter:SetActive((state))
end

function TeleportPlayer()
    print("Called Teleport To Game")
    playerTeleportatedToRace:FireServer()
end

function PlayerTeleportedToRace(player)
    player.character.transform.position = Vector3.new(0,0,0)
    playerTeleportationEvent:FireAllClients(player,0,0,0,false)
    players[player] = {
        player = player,
        playerId = player.id,
        blockIndex = 0
    }
    if(#players >= minimumNumberOfPlayers) then
        if(not waitingForPlayer) then
            waitingForPlayersEvent:FireAllClients(waitingForPlayersEvent, colorString)
            if (not gameStarted) then
                StartWaitingForPlayer()
            end
        end
    end
end

--- Handling Teleportation

--- Handling Game To Lobby Teleportation

local playerTeleportatedToLobby = Event.new("playerTeleportatedToLobby")
function TeleportPlayerToLobby()
    print("Called Teleport To Lobby")
    playerTeleportatedToLobby:FireServer()
end
function PlayerTeleportatedToLobby(player)
    players[player] = nil
    currentRacePlayers[player] = nil
    local playerIndexInWinList = table.find(winPlayers, player) 
    if playerIndexInWinList ~= nil then
        table.remove(winPlayers, playerIndexInWinList)
    end

    if (gameStarted and (#currentRacePlayers <= 0)) then
        endTheCurrentGame = true
    end

        --print("Player left", #players, #currentRacePlayers, #winPlayers,  player.name)
    if(#players < minimumNumberOfPlayers) then
        if(gameStarted or waitingForPlayer) then
            endTheCurrentGame = true
        else 
            endGame()
        end
    end
    player.character.transform.position = Vector3.new(1000,0,0)
    playerTeleportationEvent:FireAllClients(player,1000,0,0,true)
end

--- Handling Game To Lobby Teleportation

local function TrackPlayers(game, characterCallback)
    scene.PlayerJoined:Connect(function(scene, player)
        table.insert(allPlayers,player)
        changeTeleporterState:FireClient(player,not gameStarted)
        if(gameStarted) then
            setTextForWaitingForRace:FireClient(player,"Waiting for current race to end")
        end
        player.CharacterChanged:Connect(function(player, character)
            local playerinfo = players[player]
            if(character == nil) then
                return
            end

            if characterCallback then 
                characterCallback(playerinfo)
            end
        end)
        Timer.After(
            0, 
            function()
                -- spwanPointLobby=lobbySpwanPoints:GetChild(math.random(0, lobbySpwanPoints.childCount-1)).transform
                -- print("Respawning at : "..tostring(spwanPointLobby.x)..tostring(spwanPointLobby.x)..tostring(spwanPointLobby.x))
                player.character.transform.position = Vector3.new(1000,0,0)
                playerTeleportationEvent:FireAllClients(player,1000,0,0,true)
            end
        )
    end)

    scene.PlayerLeft:Connect(function(scene, player)
        
        local indexInAllPlayers=table.find(allPlayers, player)
        if(indexInAllPlayers~=nil) then
        table.remove(allPlayers,indexInAllPlayers)
        end
        players[player] = nil
        currentRacePlayers[player] = nil
        local playerIndexInWinList = table.find(winPlayers, player) 
        if playerIndexInWinList ~= nil then
            table.remove(winPlayers, playerIndexInWinList)
        end

        if (gameStarted and (#currentRacePlayers <= 0)) then
            endTheCurrentGame = true
        end

        --print("Player left", #players, #currentRacePlayers, #winPlayers,  player.name)
        if(#players < minimumNumberOfPlayers) then
            if(gameStarted or waitingForPlayer) then
                endTheCurrentGame = true
            else 
                endGame()
            end
        end

    end)

end

function getParticipatedPlayers()

    local participcatedPlayers = {}
    for k, v in pairs(currentRacePlayers) do 
        if table.find(winPlayers, v.player) ~= nil then continue end
    
        table.insert(participcatedPlayers, v)

    end

    return participcatedPlayers

end

local function compareByBlockIndex(player1, player2)
    return player1.blockIndex > player2.blockIndex
end


function endGame()
    print("Ending Game")


    
    local playersStatsForLeaderboard = {}

    local currentPosition = 1

    for i = 1, #winPlayers, 1 do
        local playerScoreBasedOnPosition = nil
        if i > 3 then
            playerScoreBasedOnPosition = utilsScript.getScore("Completed")
        else 
            playerScoreBasedOnPosition = utilsScript.getScore(tostring(i))
        end
        local value = {
            positionOnLeaderboard = currentPosition,
            playerName = winPlayers[i].name,
            playerScore = playerScoreBasedOnPosition
        }
        table.insert(playersStatsForLeaderboard, currentPosition, value)

        
        currentPosition += 1
        print("Calculating win players")
    end
    

    local storageArray = getParticipatedPlayers()
    table.sort(storageArray, compareByBlockIndex)
    for i = 1, #storageArray, 1 do 
        storageArray[i].player.character.transform.position = Vector3.new(1000,0,0)
        playerTeleportationEvent:FireAllClients(storageArray[i].player,1000,0,0,true)
        if storageArray[i].blockIndex == 0 then continue end
        local value = {
            positionOnLeaderboard = currentPosition,
            playerName = storageArray[i].player.name,
            playerScore = utilsScript.getScore("NotCompleted")
        }
        table.insert(playersStatsForLeaderboard, currentPosition, value)
        currentPosition += 1
    end
    serverStorageManager.UpdateLeaderBoardFromServer(playersStatsForLeaderboard)
    restartGameEvent:FireAllClients(playersStatsForLeaderboard)
    --print("Current paths on server are : ", colorString)
    generatePathColorsForCurrentGame()
    
    for k,v in pairs(players) do 
        players[k]=nil
    end

    Timer.After(10, function()  
        currentColor = ""
        currentRound = 0
        roundState = false
        waitingForPlayer = false
        gameStarted = false
        table.clear(winPlayers)
        endTheCurrentGame = false
        changeTeleporterState:FireAllClients(true)
        setTextForWaitingForRace:FireAllClients("")
        -- if(#players < minimumNumberOfPlayers) then return end
        -- waitingForPlayersEvent:FireAllClients(waitingForPlayersEvent, colorString)
        -- StartWaitingForPlayer()
    end)
end


function StartWaitingForPlayer()
    print("Waiting for Players")

    waitingForPlayer = true
    changeTeleporterState:FireAllClients(true)
    setTextForWaitingForRace:FireAllClients("")
    lobbyTimer = Timer.After(lobbyTime, function() 
        StartGameplayRounds()    
    end)
end

function StartGameplayRounds()
    gameStarted = true
    for i=1,#allPlayers,1 do
        if(players[allPlayers[i]]==nil) then
            print("setting For"..tostring(allPlayers[i]))
            setTextForWaitingForRace:FireClient(allPlayers[i],"Waiting for current race to end")
        end
    end
    changeTeleporterState:FireAllClients(false)
    print("Waiting for player is over.. ! Starting game")

    currentRacePlayers = table.clone(players)

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
    if(currentRound > maxRounds or endTheCurrentGame) then 
        endGame()
        return
    end
    serverRoundChangeEvent.FireAllClients(serverRoundChangeEvent, currentColor, roundState, currentRound)

    roundState = not roundState

    Timer.After(roundTime, function() 
        ApplyRoundState()
    end)
end

function UpdateCurrentPlayerColor(colorKey)
    currentPlayerColor = colorKey
end

function gameEndReachedAtClient()
    spwanPointLobby=lobbySpwanPoints:GetChild(math.random(0, lobbySpwanPoints.childCount-1)).transform
    Timer.After(
        5,
        function()
            playerTeleportationRequest:FireServer(spwanPointLobby.position.x,spwanPointLobby.position.y,spwanPointLobby.position.z,true)    
        end
    )
    gameEndReachedAtClientRequest.FireServer(gameEndReachedAtClientRequest)
    showInMessageBox = false
    mainUI.setMessageText("Race Completed..!")
    raceWon = true
    currentPlayerColor = ""
    Timer.After(5, function() if raceWon then mainUI.setMessageText("Waiting for race to complete..!") end end)
end



function BindClientEventsToServer()

    playerTeleportatedToRace:Connect(
        function(player)
            PlayerTeleportedToRace(player)
        end
    )
    playerTeleportatedToLobby:Connect(
        function(player)
            PlayerTeleportatedToLobby(player)
        end
    )
    clientConnectionRequest:Connect(function(player, args)
        print("client connected : ", player.name)
        clientDataRecieveEvent.FireAllClients(clientDataRecieveEvent, player, currentRound, currentColor, colorString, gameStarted, waitingForPlayer)
        serverStorageManager.UpdateLeaderBoardFromServer(
            {
                {
                    playerName = player.name,
                    playerScore = 0
                }
            }
        )
    end)

    playerTeleportationRequest:Connect(function(player, x,y,z,isInLobby)
        --print("respawn position is : ", position)
        player.character.transform.position = Vector3.new(x,y,z)
        playerTeleportationEvent:FireAllClients(player,x,y,z,isInLobby)
    end)

    gameEndReachedAtClientRequest:Connect(function(player)
        print("Player End Reached At Server.. ! Adding to winner list : ", player.name)
        table.insert(winPlayers, #winPlayers + 1, player)

        print("players reached end .. ! : ", #winPlayers)
        print("players in race .. !", #currentRacePlayers)

        if(#winPlayers <= 3) then
            playerPositionReachedEvent:FireAllClients(player, #winPlayers)
        end


        if #winPlayers >= #currentRacePlayers then
            endTheCurrentGame = true
        end

    end)

    serverUpdateColorRequest:Connect(function(player, colorKey, blockIndex, isDisabled)

        if blockIndex > currentRacePlayers[player].blockIndex then 
            currentRacePlayers[player].blockIndex = blockIndex
        end

        serverUpdateColorEvent:FireAllClients(player, colorKey, isDisabled)
    end)
    serverGameEndRequest:Connect(function(player, args)
        serverGameEndEvent:FireAllClients(player)
    end)    
end

function self:ClientAwake()

    mainUI = uiManager:GetComponent("MainUI")
    startPosition = Camera.main.transform.position
    
    changeTeleporterState:Connect(
        function(state)
            ChangeTeleportedState(state)
        end
    )
    setTextForWaitingForRace:Connect(
        function(Text)
            mainUI.SetNextRaceText(Text)       
        end
    )
    clientDataRecieveEvent:Connect(function(player, currentRoundOnServer, currentColorOnServer, colorblocksString, gameStarted, waitingForPlayer)
        if(player ~= client.localPlayer) then return end

        mainUI.setRoundText("ROUND " .. tostring(currentRoundOnServer) .. "/15")
        mainUI.updateRoundColor(currentColorOnServer)
        colorBlockManager:GetComponent("ColorBlockManager").UpdateGamePathColors(colorblocksString)
        if(gameStarted == true) then
            mainUI.setMessageText("Wait fot the next race")
            startClientTimerWithTime(roundTime, false)    
            spwanPointLobby=lobbySpwanPoints:GetChild(math.random(0, lobbySpwanPoints.childCount-1)).transform
            playerTeleportationRequest:FireServer(spwanPointLobby.position.x,spwanPointLobby.position.y,spwanPointLobby.position.z,true)       
            colorBlockManager:GetComponent("ColorBlockManager").UpdateWaitGameStatus(true)
        elseif(waitingForPlayer) then
            mainUI.setMessageText("Waiting For Players")
            startClientTimerWithTime(lobbyTime, false)
        end
        mainUI:enableInstructions()
    end)
    serverGameStartEvent:Connect(function(currentRoundOnServer, currentColorOnServer)
        print("Recieved GameStart")
        mainUI.setRoundText("ROUND " .. tostring(currentRoundOnServer) .. "/15")
        mainUI.updateRoundColor(currentColorOnServer)
        mainUI.hideMessageBox()        
        colorBlockManager:GetComponent("ColorBlockManager").UpdateLayerToTappable(true)
        startLineBarrier:SetActive(false)
        startClientTimerWithTime(roundTime, false)
    end)

    serverRoundChangeEvent:Connect(function(currentColor, roundState, currentRoundOnServer)
        --print("color", currentColor, roundState)

        if(roundState == false) then
            if(currentPlayerColor == nil or currentPlayerColor =="") then 
            
            elseif(currentPlayerColor ~= currentColor and raceWon == false) then 
                playerTeleportationRequest:FireServer(respawnPoint.transform.position.x,respawnPoint.transform.position.y,respawnPoint.transform.position.z,false)
                deathSound:Play()
            end
            mainUI.updateRoundColor("")
            startClientTimerWithTime(roundTime, true)
        else
            mainUI.setRoundText("ROUND " .. tostring(currentRoundOnServer) .. "/15")
            mainUI.updateRoundColor(currentColor)
            startClientTimerWithTime(roundTime, false)
            mainUI.hideMessageBox()
        end
        startLineBarrier:SetActive(not roundState)
        colorBlockManager:GetComponent("ColorBlockManager").ApplyBlockStates(currentColor, roundState)
    end)

    playerTeleportationEvent:Connect(function(player,x,y,z,isInLobby)
        player.character:Teleport(Vector3.new(x, y, z))
        if(player ~= client.localPlayer) then return end
        cameraObject:GetComponent("MainCameraMovementControl").IsInLobby=isInLobby
        cameraObject:GetComponent("RTSCamera").CenterOn(Vector3.new(x,y,z))
        currentPlayerColor = ""
    end)

    clientConnectionRequest.FireServer(clientConnectionRequest)

    serverGameEndEvent:Connect(function(player)
        if player ~= client.localPlayer then return end
        gameEndReachedAtClient()
    end)

    serverUpdateColorEvent:Connect(function(player, colorKey, isDisabled)
        if player ~= client.localPlayer then return end 
        if isDisabled then             
            playerTeleportationRequest:FireServer(respawnPoint.transform.position.x,respawnPoint.transform.position.y,respawnPoint.transform.position.z,false)
            deathSound:Play()
        else
            UpdateCurrentPlayerColor(colorKey)
        end
    end)

    serverGameTimerSyncEvent:Connect(function(currentTime)
        mainUI.setTimerText(tostring(currentTime))
    end)

    restartGameEvent:Connect(function(playersStatsForLeaderboard)
        restartGameAtClient(playersStatsForLeaderboard)
    end)

    waitingForPlayersEvent:Connect(function(event, currentPathColorsOnServer)
        -- playerTeleportationRequest:FireServer(respawnPoint.transform.position.x,respawnPoint.transform.position.y,respawnPoint.transform.position.z,false)  
        finishLine.gameObject:SetActive(true)
        startClientTimerWithTime(lobbyTime, false)        
        mainUI.updateRoundColor("")
        mainUI.setMessageText("Waiting For Players")
        mainUI.setRoundText("ROUND 0/15")
        mainUI.setLeaderboardState(false)
        --print("recieved String is : ", currentPathColorsOnServer)
        if (currentPathColorsOnServer ~= "") then            
            colorBlockManager:GetComponent("ColorBlockManager").UpdateGamePathColors(currentPathColorsOnServer)
        end
        colorBlockManager:GetComponent("ColorBlockManager").UpdateWaitGameStatus(false)
    end)

    playerPositionReachedEvent:Connect(function(winningPlayer, positionAt)
        mainUI.showPositions(positionAt, winningPlayer)
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

function restartGameAtClient(playersStatsForLeaderboard)
    colorBlockManager:GetComponent("ColorBlockManager").ApplyBlockStates("1", true)
    colorBlockManager:GetComponent("ColorBlockManager").UpdateLayerToTappable(false)
    currentPlayerColor = ""
    raceWon = false
    showInMessageBox = false
    startClientTimer = false
    mainUI.setMessageText("Restarting Game .. ! Randomizing Tiles ..!")
    mainUI.setRoundText("ROUND 0/15")
    mainUI.setTimerText("0")
    startLineBarrier:SetActive(true)
    finishLine.gameObject:SetActive(false)
    mainUI.fillLeaderboard(playersStatsForLeaderboard)

    Timer.After(10, function()  
        mainUI.updateRoundColor("")
        mainUI.setMessageText("Waiting For Players")
        mainUI.setRoundText("ROUND 0/15") mainUI.setLeaderboardState(false) end)
end
