local constants = require("Constants")
--!SerializeField
local blockMaterial : MeshRenderer = nil

local gameManager = require("GameManager")
colorKey = ""

function UpdateColor(_key)
    colorKey = _key
    if(_key == "1") then
        blockMaterial.material.color = Color.red
    elseif(_key == "2") then
        blockMaterial.material.color = Color.green
    elseif(_key == "3") then      
        blockMaterial.material.color = Color.blue
    elseif(_key == "4") then      
        blockMaterial.material.color = Color.yellow
    elseif(_key == "5") then     
        blockMaterial.material.color = Color.white
    end    
end

function self:ClientAwake()
    function self:OnTriggerEnter(other : Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil) then return end

        local player = playerCharacter.player
        if(client.localPlayer == player) then
            gameManager.updateClientColorRequest:FireClient(gameManager.updateClientColorRequest, colorKey)
        end
    end
end

--[[
function self:ClientStart()
    UpdateColor(tostring(colorKey))
end
]]