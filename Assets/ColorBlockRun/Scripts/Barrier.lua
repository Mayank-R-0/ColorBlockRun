triggerRequest = Event.new("TriggerRequest")
triggerEvent = Event.new("TriggerEvent")
--!SerializeField
local respawnPoint : Transform = nil

local gameManager = require("GameManager")

function self:ClientAwake()
    
    function self:OnTriggerEnter(other : Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil) then return end

        local player = playerCharacter.player
        if(client.localPlayer == player) then               
            gameManager.clientEventRequest:FireClient(gameManager.clientEventRequest, "GameEndReached")
        end
    end
end