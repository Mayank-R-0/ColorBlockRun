function randomBetween()
    local min = 1
    local max = 5
    local rand = math.random(min,max)
    return rand
end

function GetColor(_key)
    if(_key == "1") then
        return "RED"
    elseif(_key == "2") then
        return "GREEN"
    elseif(_key == "3") then      
        return "BLUE"
    elseif(_key == "4") then      
        return "YELLOW"
    elseif(_key == "5") then     
        return "WHITE"
    end   
end

EventKey = {
    RepositionToStart = "RepositionToStart",
    RepositionToEnd = "RepositionToEnd",
}
