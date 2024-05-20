--!Type(UI)
--!SerializeField
local isHud : boolean = false
--!SerializeField
local isHudTrue: boolean = false
--!SerializeField
local HUD : GameObject = nil
--!SerializeField
local isOverallLeaderboard : boolean = false

--!Bind
local LeaderboardContainer : VisualElement = nil
--!Bind
local LeaderboardEntryContainer : UIScrollView = nil
--!Bind
local LeaderboardTitle : UILabel = nil

--!Bind
local SelfRank : UILabel = nil
--!Bind
local SelfName : UILabel = nil
--!Bind
local SelfScore : UILabel = nil

local leaderboard=nil
function self:ClientAwake()
    if(isHud) then return end
    function self:OnTriggerEnter(other:Collider)
        if(other.gameObject:GetComponent(Character)~=nil and other.gameObject:GetComponent(Character).player==client.localPlayer) then
            -- self:GetComponent(MeshRenderer).enabled=true
            -- LeaderboardContainer.visible = true
            if(leaderboard~=nil) then
                HUD:SetActive(true)
                isHudTrue=true
                HUD:GetComponent("Leaderboard").SetupLeaderboard(leaderboard)
            end
        end
    end

    function self:OnTriggerExit(other:Collider)
        if(other.gameObject:GetComponent(Character)~=nil and other.gameObject:GetComponent(Character).player==client.localPlayer) then
            -- self:GetComponent(MeshRenderer).enabled=false
            -- LeaderboardContainer.visible = false
            HUD:SetActive(false)
            isHudTrue=false
        end
    end
end 

function SetupLeaderboard(LeaderboardData)

    leaderboard=LeaderboardData
    if(isHudTrue) then
        HUD:GetComponent("Leaderboard").SetupLeaderboard(leaderboard)
    end
    if isOverallLeaderboard then
        LeaderboardTitle:SetPrelocalizedText("OVERALL LEADERBOARD", false)
    else
        LeaderboardTitle:SetPrelocalizedText("SEASONAL LEADERBOARD", false)
    end

    LeaderboardEntryContainer:Clear()

    for i = 1, #LeaderboardData, 1 do

        local sampleVisualElement = VisualElement.new()

        sampleVisualElement:AddToClassList("scrollBoxVisualElement")

        local lable1 = UILabel.new()
        lable1:SetPrelocalizedText( tostring(i) .. ".", false)
        local lable2 = UILabel.new()
        lable2:SetPrelocalizedText( LeaderboardData[i].Name, false)
        local lable3 = UILabel.new()
        lable3:SetPrelocalizedText( tostring(LeaderboardData[i].Value), false)

        lable1:AddToClassList("scrollBoxText")
        lable2:AddToClassList("scrollBoxText")
        lable3:AddToClassList("scrollBoxText")

        sampleVisualElement:Add(lable1)
        sampleVisualElement:Add(lable2)
        sampleVisualElement:Add(lable3)

        LeaderboardEntryContainer:Add(sampleVisualElement)

        if LeaderboardData[i].Name == client.localPlayer.name then
            
            SelfRank:SetPrelocalizedText( tostring(i) .. ".", false)
            SelfName:SetPrelocalizedText( LeaderboardData[i].Name, false)
            SelfScore:SetPrelocalizedText( tostring(LeaderboardData[i].Value), false)

        end
    end
end

