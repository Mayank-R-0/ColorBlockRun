--!SerializeField
local colorBlockManager : GameObject = nil
--!SerializeField
local gameEndBarrier : GameObject = nil
--!SerializeField
local isStartingLine : boolean = false

function self:ClientAwake()
    function self:OnTriggerEnter(other:Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil) then return end

        local player = playerCharacter.player
        if(client.localPlayer == player) then
            if(isStartingLine) then
                colorBlockManager:GetComponent("ColorBlockManager").updatePlayerColor("", 0)
            else
                --gameEndBarrier:SetActive(true)
                self.gameObject:SetActive(false)
                print("Game End Reached")
                colorBlockManager:GetComponent("ColorBlockManager").gameEndReached()
            end
        end
    end
end