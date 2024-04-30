playerPositionRequest = Event.new("PlayerPositionRequest")
playerPositionEvent = Event.new("PlayerPositionEvent")
--!SerializeField
local respawnPoint : Transform = nil

function self:ClientAwake()
    playerPositionEvent:Connect(function(player)
        player.character:Teleport(respawnPoint.position)
    end)

end

function self:ServerAwake()
    playerPositionRequest:Connect(function(player, position)
        player.character.transform.position = position
        playerPositionEvent:FireAllClients(player)
    end)
end

function ApplyPlayerPosition()
    playerPositionRequest:FireServer(respawnPoint.position)
end