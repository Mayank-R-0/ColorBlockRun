--!Type(Client)

--!SerializeField
local GamePlayManager : GameObject = nil

function self:ClientAwake()
    function self:OnTriggerEnter(other:Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil) then return end
        GamePlayManager:GetComponent("GameplayManager").TeleportPlayer()
    end
end