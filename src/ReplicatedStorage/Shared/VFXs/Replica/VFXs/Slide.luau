local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TweenService = game:GetService("TweenService")

local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local CameraShaker = require(ReplicatedStorage.Shared.Utilities.Modules.CameraShaker)
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local camera = workspace.CurrentCamera

local Shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value +1, function(cf)
    camera.CFrame *= cf
end)
Shaker:Start()

local Effects = {}



Effects['Client'] = 
{
    ['Start'] = function(args)
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        if not Character then return end
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart
        if not RootPart then return end

        TaskManager:CreateTask(args.Player, 'SlideCameraEffect', 0, function(a0)
            
            while task.wait(1/10) do
                print(RootPart.AssemblyLinearVelocity.Magnitude/150)
                Shaker:ShakeOnce(math.clamp(RootPart.AssemblyLinearVelocity.Magnitude/150, 0, 2), math.clamp(RootPart.AssemblyLinearVelocity.Magnitude/5, 1, 75), 0, .1)
            end 
        end)
    end;
    ['Stop'] = function(args)
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        if not Character then return end
            
        TaskManager:CancelTask(Player, 'SlideCameraEffect')
    end
}




return Effects