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
        blockMesh.material.color = Color.new(0.9, 0.16, 0.16)
    elseif(colorKey == "2") then
        blockMesh.material.color = Color.new(0.2, 0.9, 0.2)
    elseif(colorKey == "3") then
        blockMesh.material.color = Color.new(0.93, 0.93, 0.25)
    elseif(colorKey == "4") then
        blockMesh.material.color = Color.new(0.54, 0.27, 0.87)
    elseif(colorKey == "5") then
        blockMesh.material.color = Color.new(0.22, 0.9, 0.9)
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