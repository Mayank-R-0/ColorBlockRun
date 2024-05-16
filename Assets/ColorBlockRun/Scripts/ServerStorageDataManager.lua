--!Type(Module)

local utilsScript = require("Utils")

local serverDataGetRequest = Event.new("serverDataGetRequest")

local overallLeaderboardKey = "OverallLeaderboardDataTable"
local seasonalLeaderboardKey = "SeasonalLeaderboardDataTable"

local updatePlayerDataRequest = Event.new("UpdatePlayerDataRequest")
local updatePlayerDataResponse = Event.new("UpdatePlayerDataResponse")

local overallLeaderBoardUpdatedResponse = Event.new("OverallLeaderBoardUpdatedResponse")
local seasonalLeaderBoardUpdatedResponse = Event.new("SeasonalLeaderBoardUpdatedResponse")

--!SerializeField
local overallLeaderboardUI : GameObject = nil
--!SerializeField
local seasonalLeaderboardUI : GameObject = nil


function DeleteLeaderboardData()

    Storage.DeleteValue(overallLeaderboardKey)
    Storage.DeleteValue(seasonalLeaderboardKey)

end

function updatePlayerDataOnLeaderboard(newScore)
    updatePlayerDataRequest:FireServer(newScore)
end

local function BindServerResponseToClient()
    
    overallLeaderBoardUpdatedResponse:Connect(function(updatedOverallLeaderboardData)
        listOFLeaderboard=utilsScript.getPlayerLeaderboardSortedList(updatedOverallLeaderboardData)
        overallLeaderboardUI:GetComponent("Leaderboard").SetupLeaderboard(listOFLeaderboard)
    end)

    seasonalLeaderBoardUpdatedResponse:Connect(function(updatedSeasonalLeaderboardData)
        listOFLeaderboard=utilsScript.getPlayerLeaderboardSortedList(updatedSeasonalLeaderboardData)

        seasonalLeaderboardUI:GetComponent("Leaderboard").SetupLeaderboard(listOFLeaderboard)
        
    end)

end

local function ClientInitialize()

    --serverDataGetRequest:FireServer()

end




local function UpdateLeaderBoard(player,newScore,key,eventToEmit)
    Storage.UpdateValue(key,
        function(onStorageLeaderboardData)
            if onStorageLeaderboardData == nil then
                onStorageLeaderboardData = {
                    [player.name] = newScore
                }
                print("1. Updating value of " .. player.name .. " with " .. tostring(newScore))
                eventToEmit:FireAllClients(onStorageLeaderboardData)
                return onStorageLeaderboardData
            elseif(onStorageLeaderboardData[player.name] == nil) then
                print("2. Updating value of " .. player.name .. " with " .. tostring(newScore))
                onStorageLeaderboardData[player.name] = newScore
                eventToEmit:FireAllClients(onStorageLeaderboardData)
                return onStorageLeaderboardData
            else
                onStorageLeaderboardData[player.name]=onStorageLeaderboardData[player.name]+newScore
                print("3. Updating value of " .. player.name .. " with " .. tostring(newScore))
                eventToEmit:FireAllClients(onStorageLeaderboardData)
                return onStorageLeaderboardData
            end
        end
        )
end

function UpdateLeaderBoardFromServer(player, newScore)

    UpdateLeaderBoard(player, newScore, overallLeaderboardKey, overallLeaderBoardUpdatedResponse)
    UpdateLeaderBoard(player, newScore, seasonalLeaderboardKey, seasonalLeaderBoardUpdatedResponse)

end

local function getUpdatedLeaderboard(player,key,eventToEmit)
    Storage.GetValue(key, function(leaderBoardData)
        eventToEmit:FireClient(player,leaderBoardData)
    end)
end

local function BindClientRequestsToServer()


    updatePlayerDataRequest:Connect(function(player, newScore)
        UpdateLeaderBoard(player,newScore,overallLeaderboardKey,overallLeaderBoardUpdatedResponse)
        UpdateLeaderBoard(player, newScore/2, seasonalLeaderboardKey, seasonalLeaderBoardUpdatedResponse)
    end)
    serverDataGetRequest:Connect(
        function(player) 
            getUpdatedLeaderboard(player,overallLeaderboardKey, overallLeaderBoardUpdatedResponse)
            getUpdatedLeaderboard(player,seasonalLeaderboardKey, seasonalLeaderBoardUpdatedResponse)
        end
    )
end

local function ServerInitialize()
    --DeleteLeaderboardData()
end




function self:ClientAwake()
    BindServerResponseToClient()
    ClientInitialize()
end


function self:ServerAwake()
    BindClientRequestsToServer()
    ServerInitialize()
    Timer.After(3600, ResetSeasonalList)
end
function ResetSeasonalList()
    if(utilsScript.getCurrentDay()==2) then
        local current_time = os.time()
        local current_hour = tonumber(os.date("%H", current_time))
        if(current_hour>=0 and current_hour<=1) then
            Storage.DeleteValue(seasonalLeaderboardKey,function(errorCode) print("Deleting Seasonal Data Error Code "..tostring(errorCode)) end)
        end
    end
    Timer.After(3600, ResetSeasonalList)
end