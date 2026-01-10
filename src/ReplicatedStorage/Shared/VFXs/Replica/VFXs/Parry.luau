local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TweenService = game:GetService("TweenService")

local Parry = require(ReplicatedStorage.Bricksv2.Data.Registries.BehaviorRegistries.PassivesBehaviors.Parry)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local CacheContainer = require(ReplicatedStorage.Shared.Utilities.Modules.CacheContainer)
local CountHandler = require(ReplicatedStorage.Shared.Utilities.Modules.CountHandler)
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local Effects = {}
local EffectCache = CacheContainer.new()
local ParrySoundCounter = CountHandler.Create('ParrySound', 1, 3)

Effects['Parry'] = 
{
    ['Cast'] = function(args)
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        
        local DefaultAssets = Assets:FindFirstChild('Default')
        local EffectsFolder = DefaultAssets:FindFirstChild('Effects')
        local ParryCastPrototype = EffectsFolder:FindFirstChild('ParryCast')
        local ParryCast = EffectCache:CreateInstance('ParryCast', ParryCastPrototype, {
            'OutlineTransparency',
            'FillTransparency'
        })        
        ParryCast.Parent = Character

        local ParryTween = TweenService:Create(ParryCast, TweenInfo.new(.3), {
            OutlineTransparency = 1,
            FillTransparency = 1
        })
        ParryTween:Play()
        ParryTween.Completed:Once(function()
            EffectCache:AddInstanceToCache('ParryCast', ParryCast)
        end)
    end,
    ['Hit'] = function(args)
        
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

        local DefaultAssets = Assets:FindFirstChild('Default')
        local EffectsFolder = DefaultAssets:FindFirstChild('Effects')
        local SoundsFolder = DefaultAssets:FindFirstChild('Sounds')
        local SoundParry = SoundsFolder:FindFirstChild('Parry')[ParrySoundCounter()]

        local ParryEffectPrototype = EffectsFolder:FindFirstChild('Parry')
        local ParryEffect = EffectCache:CreateInstance('ParryHit', ParryEffectPrototype) :: BasePart
        local WeldConstraint = EffectCache:CreateInstance('Welds', Assets.Welds.WeldConstraint, 
        {
            'Part0';
            'Part1';
        }) :: WeldConstraint
        local ParrySound = EffectCache:CreateInstance('ParrySounds'..ParrySoundCounter(), SoundParry, {
            'Volume'
        }) :: Sound

        ParryEffect.Parent = workspace.Map.VFXs
        ParryEffect.CFrame = RootPart.CFrame

        WeldConstraint.Part0 = RootPart
        WeldConstraint.Part1 = ParryEffect

        AssetsHelper.Emit(ParryEffect)
        ParrySound.Parent = RootPart
        ParrySound:Play()

        ParrySoundCounter:Increment()
        
        ParrySound.Ended:Once(function(a0: string)
            ParrySoundCounter:Increment()
            EffectCache:AddInstanceToCache('ParrySounds', ParrySound)
        end)
        task.delay(1,function()
            EffectCache:AddInstanceToCache('ParryHit', ParryEffect)
            EffectCache:AddInstanceToCache('Welds', WeldConstraint)
        end)
        
    end
}




return Effects