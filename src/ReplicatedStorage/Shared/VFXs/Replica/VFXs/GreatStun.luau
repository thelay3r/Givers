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
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local GreatStun = {}

local AnimationsFolder = Assets.Default.Animations :: Folder
local Effects = Assets.Default.Effects :: Folder
local Sounds = Assets.Default.Sounds :: Folder

local EffectContainer = CacheContainer.new()


GreatStun['Action'] = {
    ['Effect'] = function(args)
        local Player = args.Player :: Player
        local Character = Player.Character :: Model
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

        local SoundProtorype = Sounds:FindFirstChild('GreatStun'):FindFirstChild('GreatStun')
        local GreatStunPrototype = Effects:FindFirstChild('GreatStun') :: BasePart
        local GreatStunEffect = EffectContainer:CreateInstance('GreatStun', GreatStunPrototype) :: BasePart
        local Weld = EffectContainer:CreateInstance('WeldConstraint', Assets.Welds.WeldConstraint, {
            'Part1';
            'Part0';
        }):: WeldConstraint
        local GreatStunSound = EffectContainer:CreateInstance('GreatStunSound', SoundProtorype) :: Sound


        GreatStunSound.Parent = RootPart
        GreatStunSound:Play()
        GreatStunSound.Ended:Once(function(a0: string)  
            EffectContainer:AddInstanceToCache('GreatStunSound', GreatStunSound)
        end)
        
        GreatStunEffect.CFrame = RootPart.CFrame
        Weld.Part0 = RootPart
        Weld.Part1 = GreatStunEffect

        GreatStunEffect.Parent = workspace.Map.VFXs
        Weld.Parent = GreatStunEffect

        AssetsHelper.Emit(GreatStunEffect)

        task.delay(2, function()
            EffectContainer:AddInstanceToCache('GreatStun', GreatStunEffect)
            EffectContainer:AddInstanceToCache('WeldConstraint', Weld)
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