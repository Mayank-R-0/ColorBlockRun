local constants = require("Constants")
--!SerializeField
local blockMaterial : MeshRenderer = nil

colorKey = nil
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
