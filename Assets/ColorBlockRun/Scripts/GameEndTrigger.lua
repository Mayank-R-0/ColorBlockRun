--[[
    Start and Finish line trigger
]]

--!SerializeField
local colorBlockManager : GameObject = nil  -- Reference of block manager to send the end/start reached events
--!SerializeField
local isStartingLine : boolean = false      -- Wheather this is a start line or finish line, if start line then make sure this is true

-- Awake method to bind OnTriggerEnter
function self:ClientAwake()
    function self:OnTriggerEnter(other:Collider)
        local playerCharacter = other.gameObject:GetComponent(Character)
        if(playerCharacter == nil) then return end

        local player = playerCharacter.player
        if(client.localPlayer == player) then
            if(isStartingLine) then
                colorBlockManager:GetComponent("ColorBlockManager").updatePlayerColor("", 0)    -- if we go onto the color blocks and get back to finish line we need to set the player color back to nil
            else
                self.gameObject:SetActive(false)
                print("Game End Reached")
                colorBlockManager:GetComponent("ColorBlockManager").gameEndReached()            -- When reached end need to make sure that player race is finished
            end
        end
    end
end