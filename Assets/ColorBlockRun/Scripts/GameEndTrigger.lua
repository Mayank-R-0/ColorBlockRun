--!SerializeField
local colorBlockManager : GameObject = nil
--!SerializeField
local gameEndBarrier : GameObject = nil

function self:ClientAwake()
    function self:OnTriggerEnter(other:Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil) then return end

        local player = playerCharacter.player
        if(client.localPlayer == player) then
            gameEndBarrier:SetActive(true)
            self.gameObject:SetActive(false)
            print("Game End Reached")
            colorBlockManager:GetComponent("ColorBlockManager").gameEndReached()
        end
    end
end