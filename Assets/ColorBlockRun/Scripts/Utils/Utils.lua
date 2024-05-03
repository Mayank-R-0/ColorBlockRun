local min = 1 
local max = 5

NumberOfColorBlocks = 200

function getRandom()
    local random = math.random(min, max)
    return random
end

function getRandomNumbers(--[[Optional]]randomNumberCount)
    randomNumberCount = randomNumberCount or NumberOfColorBlocks
    local randomNumbers = {}
    for i = 1, randomNumberCount, 1 do
        table.insert(randomNumbers, math.random(min, max))
    end
    return randomNumbers
end

function getRandomNumbersAsString(--[[Optional]]randomNumberCount)
    randomNumberCount = randomNumberCount or NumberOfColorBlocks
    local randomNumbers = getRandomNumbers(randomNumberCount)

    local numberString = ""
    for i = 1, randomNumberCount, 1 do
        numberString = numberString .. randomNumbers[i] .. ","
    end
    return numberString
end

function splitRandomNumbersString(dataString)
    local substrings = {}
    for substring in dataString:gmatch("[^,]+") do
        table.insert(substrings, substring)
    end
    return substrings
end
