--[[
    Individual color block properties
]]

--!SerializeField
local blockMesh : MeshRenderer = nil -- Mesh reference to access the material

--[[
    Blocker stop the player from moving outside the box in which they are currently standing
]]
--!SerializeField
local leftBlocker : GameObject = nil -- Left Blocker, Blocks from left
--!SerializeField
local rightBlocker : GameObject = nil -- Right Blocker, Blocks from right
--!SerializeField
local frontBlocker : GameObject = nil -- Front Blocker, Blocks from front
--!SerializeField
local backBlocker : GameObject = nil -- Back Blocker, Blocks from Back

--!SerializeField
local disabledCollider : GameObject = nil  -- Collider to enable when the block turned off so players cannot pass through them

--[[
    Variables
]]
colorKey = ""  -- This blocks assigned color ID
local blockIndex = 0   -- This blocks assigned index on the path (from Left to Right)

--[[
    Functions
]]
-- Change the material color of the block with assigned color id as random number between 1 to 5
-- Also the index of the block
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

-- Client Awake Method, Adds OnTriggerEnter Callback to update on which color block currently player is standing
function self:ClientAwake()
    function self:OnTriggerEnter(other:Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil) then return end

        local player = playerCharacter.player
        if(client.localPlayer == player) then
            -- When the local player activates the trigger values of this blocks is set as the currently activated color block in the Manager
            self.transform.parent:GetComponent("ColorBlockManager").updatePlayerColor(colorKey, blockIndex, false)
        end
    end
end

-- Function sets the state of blockers, When to enable/disable them
function SetBlockersState(enable)
    leftBlocker:SetActive(enable)
    rightBlocker:SetActive(enable)
    frontBlocker:SetActive(enable)
    backBlocker:SetActive(enable)
end

function SetBlockState(blockState)
    blockMesh.gameObject:SetActive(blockState)
    self.gameObject:GetComponent(BoxCollider).enabled = blockState
    disabledCollider:GetComponent(BoxCollider).enabled = not blockState
end