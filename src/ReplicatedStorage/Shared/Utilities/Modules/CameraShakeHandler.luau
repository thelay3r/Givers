local CameraShaker = require(script.Parent.CameraShaker)


local Camera = workspace.CurrentCamera
local Handler = {}
local Methods = {}

type ICamera = {
    Camera : typeof(CameraShaker)
}

function Methods.ShakeOnce(self:ICamera ,mag,roug,In,Out)
    self.Camera:ShakeOnce(mag, roug, In, Out)
end

function Methods.ShakeByDistance(self:ICamera ,mag,roug,In,Out)
    self.Camera:ShakeOnce(mag, roug, In, Out)
end

function Handler.new() : ICamera
    local self = setmetatable(
        {
            Camera = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, function(cf)
                Camera.CFrame *= cf
            end)
        }, {
            __index = function(_,key)
                return Methods[key]
            end
        })
    
    self.Camera:Start()
    return self
end

return Handler