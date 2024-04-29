local c = require("Constants")
local gameManagerModule = require("GameManager")
local colorBlockComponents : ColorBlock = {}

function FillChildComponents()
    for i = 0, self.transform.childCount - 1, 1 do
        table.insert(colorBlockComponents, self.transform:GetChild(i):GetComponent("ColorBlock"))
    end
end

function SetOtherBlocksState(blockColor, isEnable)
    print("Blocksssssss", blockColor)
    for colorBlockIndex in colorBlockComponents do
        if(colorBlockComponents[colorBlockIndex].colorKey ~= blockColor) then
            colorBlockComponents[colorBlockIndex].gameObject:SetActive(isEnable)
        end 
    end
end

function UpdateColors(dataString)
    local substrings = {}
    for substring in dataString:gmatch("[^,]+") do
        table.insert(substrings, substring)
    end

    for i = 1, 100, 1 do
        colorBlockComponents[i].UpdateColor(substrings[i])
    end
end


function self:ClientAwake()
   FillChildComponents()
   print("Awake:", gameManagerModule)
   gameManagerModule.roundEvent:Connect(function(...)
    print("Event received!!")
    SetOtherBlocksState(...)
   end)

   gameManagerModule.gameSetupEvent:Connect(function(...)
    print("SetupEventRecieved...!")
    UpdateColors(...)
   end)

   gameManagerModule.clientJoinRequest:FireServer()
   
end

    


