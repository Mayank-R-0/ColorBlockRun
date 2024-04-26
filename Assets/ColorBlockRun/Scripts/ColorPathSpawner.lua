-- --!SerializeField
-- local colorBlockTemplate : GameObject = nil
-- --!SerializeField
-- local maxColorBlockCount = 100

-- local row = 0
-- local column = 0
-- local maxColumn = 5
-- local blockSize = 1


-- function SpawnColorBlock(obj)
--     local newBlock = Object.Instantiate(obj, self.transform)
--     local newBlockTransform = newBlock.transform
--     newBlockTransform:SetParent(self.transform)

--     newBlockTransform.localPosition = Vector3.new(column * blockSize * -1, 0, row * blockSize)
--     column += 1
--     if (column >= maxColumn) then 
--         column = 0
--         row += 1
--     end
-- end

-- function SpawnBlocks()
--     for i = 0, maxColorBlockCount - 1, 1 do
--         SpawnColorBlock(colorBlockTemplate)
--     end
-- end

-- SpawnBlocks()

local c = require("Constants")
local gameManagerModule = require("GameManager")
local colorBlockComponents : ColorBlock = {}

function FillChildComponents()
    for i = 0, self.transform.childCount - 1, 1 do
        table.insert(colorBlockComponents, self.transform:GetChild(i):GetComponent("ColorBlock"))
    end
    UpdateBlockColors()
end

function UpdateBlockColors()
    for i in colorBlockComponents do
        colorBlockComponents[i].UpdateColor(tostring(c.randomBetween()))
    end
end

function SetOtherBlocksState(blockColor, isEnable)
    for colorBlockIndex in colorBlockComponents do
        if(colorBlockComponents[colorBlockIndex].colorKey ~= blockColor) then
            colorBlockComponents[colorBlockIndex].gameObject:SetActive(isEnable)
        end 
    end
end


function self:Awake()
   FillChildComponents()
   print("Awake:", gameManagerModule)

   gameManagerModule.roundEvent:Connect(function(...)
    print("Event received!!")
    SetOtherBlocksState(...)
   end)
end

    


