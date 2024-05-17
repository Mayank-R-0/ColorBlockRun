--!Type(Module)

local utilsScript = require("Utils")

local overallLeaderboardKey = "OverallLeaderboardDataTable"
local seasonalLeaderboardKey = "SeasonalLeaderboardDataTable"

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

local function BindServerResponseToClient()
    
    overallLeaderBoardUpdatedResponse:Connect(function(updatedOverallLeaderboardData)
        overallLeaderboardUI:GetComponent("Leaderboard").SetupLeaderboard(updatedOverallLeaderboardData)
    end)

    seasonalLeaderBoardUpdatedResponse:Connect(function(updatedSeasonalLeaderboardData)
        seasonalLeaderboardUI:GetComponent("Leaderboard").SetupLeaderboard(updatedSeasonalLeaderboardData)
    end)

end

local function ClientInitialize()

end


local function UpdateLeaderBoard(players,key,eventToEmit)
    Storage.UpdateValue(key,
        function(onStorageLeaderboardData)
            if(onStorageLeaderboardData==nil) then
                onStorageLeaderboardData=
                {
                    ["Test"]=0
                }
            end
            for playerData in players do
                if(onStorageLeaderboardData[players[playerData].playerName] == nil) then
                    onStorageLeaderboardData[players[playerData].playerName]=players[playerData].playerScore
                    print("1. Updating value of " .. players[playerData].playerName .. " with " .. tostring(players[playerData].playerScore))
                else
                    onStorageLeaderboardData[players[playerData].playerName]=onStorageLeaderboardData[players[playerData].playerName]+players[playerData].playerScore
                    print("2. Updating value of " .. players[playerData].playerName .. " with " .. tostring(players[playerData].playerScore))
                end
            end
            eventToEmit:FireAllClients(utilsScript.getPlayerLeaderboardSortedList(onStorageLeaderboardData))
            return onStorageLeaderboardData
        end
        )
end

function UpdateLeaderBoardFromServer(players)

    UpdateLeaderBoard(players, overallLeaderboardKey, overallLeaderBoardUpdatedResponse)
    UpdateLeaderBoard(players, seasonalLeaderboardKey, seasonalLeaderBoardUpdatedResponse)

end

local function getUpdatedLeaderboard(player,key,eventToEmit)
    Storage.GetValue(key, function(leaderBoardData)
        eventToEmit:FireClient(player,leaderBoardData)
    end)
end

local function BindClientRequestsToServer()

end

local function ServerInitialize()
    -- DeleteLeaderboardData()
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