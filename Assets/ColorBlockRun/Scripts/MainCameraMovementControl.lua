--!Type(Client)local camera = self.gameObject:GetComponent(Camera)
IsInLobby=false;
local camera = self.gameObject:GetComponent(Camera)
if camera == nil then
    print("HighriseCameraController requires a Camera component on the GameObject its attached to.")
    return
end
local cameraRig : Transform = camera.transform 
function self:Update()
    x=cameraRig.position.x
    if(not IsInLobby) then
        if(x>250) then
            cameraRig.position=Vector3.new(50,cameraRig.position.y, cameraRig.position.z)
        end
    else 
        if(x<750) then
            cameraRig.position=Vector3.new(950,cameraRig.position.y, cameraRig.position.z)
        end
    end
end