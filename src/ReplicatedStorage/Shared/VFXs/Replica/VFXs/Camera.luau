local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')


local TweenService = game:GetService("TweenService")

local TaskManager = require(Modules:WaitForChild('TaskManager'))

local CameraVFXs = {}

local DefaultEasingStyle = Enum.EasingStyle.Sine
local DefaultEasingDirection = Enum.EasingDirection.Out

local function ChangeFov(camera,_time,fov,easingStyle, easingDirection)
    return TweenService:Create(camera, TweenInfo.new(_time,easingStyle or DefaultEasingStyle, easingDirection or DefaultEasingDirection), 
        {
            FieldOfView = fov;
        }):Play()
end

function CameraVFXs.ChangeFOV(args)

    local Player = args.Player
    local Camera = workspace.CurrentCamera
    local OriginalFOV = Camera.FieldOfView

    local _Time = args.Time or 0.5

    TaskManager:CreateTask(Player, 'ChangeFOVInit', 0, function()  
        ChangeFov(Camera,_Time,args.FOV,args.EasingStyle, args.EasingDirection)
    end)
    
    if not args.ResetAfter then return end
    task.wait((args.HoldTime or 0) + _Time)
    TaskManager:CreateTask(Player, 'ChangeFOVReset', _Time + (args.HoldTime or 0), function()  
        ChangeFov(Camera,_Time,OriginalFOV,args.EasingStyle, args.EasingDirection)
    end)

end


return CameraVFXs