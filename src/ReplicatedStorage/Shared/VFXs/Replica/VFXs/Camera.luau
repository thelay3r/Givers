local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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

local function WooblingEffect(args)
    local Player = args.Player
    local Character = Player.Character :: Model
    local Humanoid = Character:FindFirstChildOfClass('Humanoid') :: Humanoid

  	TaskManager:CreateThread(Player,'CameraWobbling',RunService.Heartbeat:Connect(function(dt)
		if Humanoid.MoveDirection == Vector3.zero then Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp(Vector3.zero,.05) TaskManager:CancelThread(Player,'CameraWobbling') return end
		local _time = tick()
		
		local x = math.cos(_time*10)/4
		local y = math.abs(math.sin(_time*10)/5)
		
		local result = Vector3.new(x,y,0)
		Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp(result,.05)
		
	end))

end

local function ChangeFOV(args)

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

CameraVFXs['Woobling'] = 
{
    ['Start'] = function(args)
        WooblingEffect(args)
    end,
    ['Stop'] = function(args)
        local Player = args.Player
        TaskManager:CancelThread(Player, 'CameraWobbling')
    end

}

CameraVFXs['ChangeFOV'] = 
{
    ['Start'] = function(args)
        ChangeFOV(args)
    end,
}



return CameraVFXs