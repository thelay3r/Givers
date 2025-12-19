local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _RunService = game:GetService("RunService")
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
    ['Test'] = function(args)
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        if not Character then return end
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart
        if not RootPart then return end
        local test = script:WaitForChild('Test'):Clone() :: Model
        
        local weld = Instance.new('WeldConstraint')
        weld.Part0 = RootPart
        weld.Part1 = test.PrimaryPart

        weld.Parent = test.PrimaryPart
        test:PivotTo(RootPart.CFrame - Vector3.new(0,1,0))
        test.Parent = workspace

  
    end;
    ['Stop'] = function(args)
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        if not Character then return end
            
        TaskManager:CancelTask(Player, 'SlideCameraEffect')
    end;
    ['Lobo'] = function(args)
        local Player = args.Player :: Player
        if not Player then return end
        local Character = Player.Character :: Model 
        if not Character then return end

        local sounds = Assets:WaitForChild('Sounds')
        local soundFolder = sounds:WaitForChild('Slide')
        
        local newHitSound = soundFolder:FindFirstChild('Hit'):Clone()
        local LoboSound = soundFolder:FindFirstChild('Sound'):Clone()

        newHitSound.Parent = args.Player.Character.PrimaryPart
        LoboSound.Parent = args.Player.Character.PrimaryPart

        AssetsHelper.PlaySound(newHitSound)
        AssetsHelper.PlaySound(LoboSound)

        task.delay(.1,function()
            Character.PrimaryPart:ApplyAngularImpulse(Vector3.new(1500,0,3500))
        end)

        Shaker:ShakeOnce(5, 50, 0, 1.3)

        local PlayerGui = Player.PlayerGui :: PlayerGui
        local NewGui = Instance.new('ScreenGui')
        NewGui.IgnoreGuiInset = true

        NewGui.Parent = PlayerGui
        local Lobo = Instance.new('Frame') :: Frame
        Lobo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Lobo.Size = UDim2.fromScale(1,1)
        Lobo.Parent = NewGui

        TweenService:Create(Lobo, TweenInfo.new(5,Enum.EasingStyle.Sine), {
           Transparency = 1;
           BackgroundTransparency = 1
        }):Play()

    end
}




return Effects