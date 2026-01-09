local Players = game:GetService("Players")

local CameraShaker = require(script.Parent.CameraShaker)


local Camera = workspace.CurrentCamera
local Handler = {}
local Methods = {}

type ICamera = {
    Camera : typeof(CameraShaker);
    ShakeOnce: (self: ICamera, magnitude: number,roughnes: number, In: number,Out: number) -> ();
    ShakeByDistance: (self: ICamera, Config : ShakeConfig) -> ();

}

type ShakeConfig = {
    StartPoint: Vector3,
    Roughness: number,
    InTime: number,
    OutTime: number,
    MagnitudeMultiplier: number?,
    MaxDistance: number?,
    MinMagnitude: number?,
    MaxMagnitude: number?,
}

function Methods.ShakeOnce(self:ICamera ,mag,roug,In,Out)
    self.Camera:ShakeOnce(mag, roug, In, Out)
end

function Methods.ShakeByDistance(self: ICamera, config: ShakeConfig)
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not RootPart then return end
    
    local multiplier = config.MagnitudeMultiplier or 1
    local maxDist = config.MaxDistance or 100
    local minMagnitude = config.MinMagnitude or 0
    local maxMagnitude = config.MaxMagnitude or 25
    
    local distance = (RootPart.Position - config.StartPoint).Magnitude
    
    if distance > maxDist then
        return
    end
    
    local magnitude = maxMagnitude * (1 - (distance / maxDist)) * multiplier
    
    magnitude = math.clamp(magnitude, minMagnitude, maxMagnitude)
    
    self.Camera:ShakeOnce(magnitude, config.Roughness, config.InTime, config.OutTime)
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