local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TweenService = game:GetService("TweenService")

local AnimationsInterfaces = require(ReplicatedStorage.Shared.Interfaces.AnimationsInterfaces)
local AnimationsComponent = require(ReplicatedStorage.Shared.Utilities.Modules.AnimationsComponent)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local CacheContainer = require(ReplicatedStorage.Shared.Utilities.Modules.CacheContainer)
local CameraShakeHandler = require(ReplicatedStorage.Shared.Utilities.Modules.CameraShakeHandler)
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local GreatStun = {}

local AnimationsFolder = Assets.Default.Animations :: Folder
local Effects = Assets.Default.Effects :: Folder
local Sounds = Assets.Default.Sounds :: Folder

local EffectContainer = CacheContainer.new()

local Shaker = CameraShakeHandler.new()
GreatStun['Action'] = {
    ['Effect'] = function(args)
        local Player = args.Player :: Player
        local Character = Player.Character :: Model
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

        local SoundProtorype = Sounds:FindFirstChild('GreatStun'):FindFirstChild('GreatStun')
        local GreatStunPrototype = Effects:FindFirstChild('GreatStun') :: BasePart
        local SubGreatStunPrototype = Effects:FindFirstChild('GreatStunSub') :: BasePart
        local GreatStunEffect = EffectContainer:CreateInstance('GreatStun', GreatStunPrototype) :: BasePart
        local GreatStunEffectSub = EffectContainer:CreateInstance('GreatStunSub', SubGreatStunPrototype) :: BasePart

        local Weld = EffectContainer:CreateInstance('Weld', Assets.Welds.Weld, {
            'Part1';
            'Part0';
        }):: WeldConstraint
        local GreatStunSound = EffectContainer:CreateInstance('GreatStunSound', SoundProtorype) :: Sound


        
        GreatStunSound.Parent = RootPart
        GreatStunSound:Play()
        GreatStunSound.Ended:Once(function(a0: string)  
            EffectContainer:AddInstanceToCache('GreatStunSound', GreatStunSound)
        end)
        
        task.delay(.35, function()
            local GroundCheck = AssetsHelper.FastCast({
                ['Character'] = Character;
                ['Direction'] = Vector3.new(0,-5,0);
                ['Position'] = Character.PrimaryPart.Position;
            })
            if not GroundCheck then return end
            GreatStunEffectSub.Parent = workspace.Map.VFXs
            GreatStunEffectSub.Anchored = true
            GreatStunEffectSub.CFrame = CFrame.new(GroundCheck.Position,GroundCheck.Position+GroundCheck.Normal) * CFrame.Angles(-math.rad(90), 0, 0)
            AssetsHelper.Emit(GreatStunEffectSub)
        end)

        GreatStunEffect.CFrame = RootPart.CFrame
        Weld.Part0 = Character.Torso
        Weld.Part1 = GreatStunEffect

        GreatStunEffect.Parent = workspace.Map.VFXs
        Weld.Parent = GreatStunEffect

        AssetsHelper.Emit(GreatStunEffect)

        task.delay(3, function()
            EffectContainer:AddInstanceToCache('GreatStun', GreatStunEffect)
            EffectContainer:AddInstanceToCache('Weld', Weld)
            EffectContainer:AddInstanceToCache('GreatStunEffectSub', GreatStunEffectSub)
        end)

    end,
    ['Animation'] = function(args)
        local Player = args.Player :: Player
        local Character = Player.Character :: Model
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

        local Animation = AnimationsFolder:FindFirstChild('GreatStun')
        local Animator = AnimationsComponent.new(Character)
        local anim,data = Animator:Load(Animation,{
            Name = 'GreatStun',
            Priority = Enum.AnimationPriority.Action3.Name,
            _Name = 'GreatStun',
            Settings =
            {
                ['Speed'] = 1,
                ['Weight'] = 1,
                ['FadeTime'] = .05,
            } 
        })
        Animator:Play(data)

    end
}


return GreatStun