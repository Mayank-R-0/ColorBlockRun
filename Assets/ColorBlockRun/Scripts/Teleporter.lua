--!Type(Client)

--!SerializeField
local GamePlayManager : GameObject = nil
--!SerializeField
local isLobbyToGame : boolean = false
function self:ClientAwake()
    function self:OnTriggerEnter(other:Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil or playerCharacter.player~=client.localPlayer) then return end
        if(isLobbyToGame) then
            GamePlayManager:GetComponent("GameplayManager").TeleportPlayer()
        else
            GamePlayManager:GetComponent("GameplayManager").TeleportPlayerToLobby()
        end
    end
end