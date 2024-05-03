--!SerializeField
local blockMesh : MeshRenderer = nil
--!SerializeField
local leftBlocker : GameObject = nil
--!SerializeField
local rightBlocker : GameObject = nil
--!SerializeField
local frontBlocker : GameObject = nil
--!SerializeField
local backBlocker : GameObject = nil


colorKey = ""
local blockIndex = 0

function UpdateBlockColor(_key, _index)
    colorKey = _key
    blockIndex = _index
    if(colorKey == "1") then
        blockMesh.material.color = Color.red
    elseif(colorKey == "2") then
        blockMesh.material.color = Color.green
    elseif(colorKey == "3") then
        blockMesh.material.color = Color.yellow
    elseif(colorKey == "4") then
        blockMesh.material.color = Color.blue
    elseif(colorKey == "5") then
        blockMesh.material.color = Color.cyan
    end
end

function self:ClientAwake()
    function self:OnTriggerEnter(other:Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil) then return end

        local player = playerCharacter.player
        if(client.localPlayer == player) then
            self.transform.parent:GetComponent("ColorBlockManager").updatePlayerColor(colorKey, blockIndex)
        end
    end
end

function SetBlockersState(enable)
    leftBlocker:SetActive(enable)
    rightBlocker:SetActive(enable)
    frontBlocker:SetActive(enable)
    backBlocker:SetActive(enable)
end