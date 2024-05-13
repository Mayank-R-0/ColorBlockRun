--!Type(Client)

function self:ClientAwake()
    function self:OnTriggerEnter(other:Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil) then return end

        local player = playerCharacter.player
        if(client.localPlayer == player) then
            self.transform.parent.parent:GetComponent("ColorBlockManager").updatePlayerColor("1", 0, true)
        end
    end
end