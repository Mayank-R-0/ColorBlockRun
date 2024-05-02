--!SerializeField
local blockMesh : MeshRenderer = nil
colorKey = ""

function UpdateBlockColor(_key)
    colorKey = _key

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
            self.transform.parent:GetComponent("ColorBlockManager").updatePlayerColor(colorKey)
        end
    end
end