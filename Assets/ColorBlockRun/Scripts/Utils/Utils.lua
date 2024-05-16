-- Module script for utility functions

local min = 1 -- Minimum value for generating random number between
local max = 5 -- Maximum value for generating random number between

NumberOfColorBlocks = 300 -- Number of maximum color blocks to generate random values for

scoreValues = {
    ["1"] = 100,
    ["2"] = 80,
    ["3"] = 50,
    ["Completed"] = 30,
    ["NotCompleted"] = 5
}

function getScore(positionKey)
    return scoreValues[positionKey]
end

-- Generate random number between min & max
function getRandom()
    local random = math.random(min, max)
    return random
end

-- Return generated random numbers as array, random numbers are generated for NumberOfColorBlocks
function getRandomNumbers(--[[Optional]]randomNumberCount)
    randomNumberCount = randomNumberCount or NumberOfColorBlocks
    local randomNumbers = {}
    for i = 1, randomNumberCount, 1 do
        table.insert(randomNumbers, math.random(min, max))
    end
    return randomNumbers
end

-- Return generated random numbers as string saperated by ',' , random numbers are generated for NumberOfColorBlocks
function getRandomNumbersAsString(--[[Optional]]randomNumberCount)
    randomNumberCount = randomNumberCount or NumberOfColorBlocks
    local randomNumbers = getRandomNumbers(randomNumberCount)

    local numberString = ""
    for i = 1, randomNumberCount, 1 do
        numberString = numberString .. randomNumbers[i] .. ","
    end
    return numberString
end

-- Method that splits the random number string back to array and return it
function splitRandomNumbersString(dataString)
    local substrings = {}
    for substring in dataString:gmatch("[^,]+") do
        table.insert(substrings, substring)
    end
    return substrings
end

-- Method that convert dictionary of Leaderboard Data into sorted array
function getPlayerLeaderboardSortedList(onStorageLeaderboardData)
    leaderboardList={}
    for k,v in pairs(onStorageLeaderboardData) do
        table.insert(leaderboardList,{["Name"]=k,["Value"]=v})
    end
    table.sort(leaderboardList,compareByScore)
    return leaderboardList
end
function compareByScore(player1, player2)
    return player1["Value"] > player2["Value"]
end

-- Method to get Current Day
function getCurrentDay()
    return os.date("*t").wday
end