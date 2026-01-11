local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TweenService = game:GetService("TweenService")

local Character = require(ReplicatedStorage.Shared.FSM_States.Character)
local AnimationsComponent = require(ReplicatedStorage.Shared.Utilities.Modules.AnimationsComponent)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local CacheContainer = require(ReplicatedStorage.Shared.Utilities.Modules.CacheContainer)
local CameraShakeHandler = require(ReplicatedStorage.Shared.Utilities.Modules.CameraShakeHandler)
local CountHandler = require(ReplicatedStorage.Shared.Utilities.Modules.CountHandler)
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local Effects = {}
local EffectCache = CacheContainer.new()
local ParrySoundCounter = CountHandler.Create('ParrySound', 1, 3)
local ParryAnimationCounter = CountHandler.Create('ParryAnimation', 1, 2)
local Shaker = CameraShakeHandler.new()

local function PlayAnimation(Character,state,state2)
    local Animator = AnimationsComponent.new(Character)
    local Animation = Assets.Default.Animations[state2][state]

    local _, data = Animator:Load(Animation,
        {
            Name = state2;
            _Name = state2..state;
            Priority = Enum.AnimationPriority.Action3.Name; 
        })
    Animator:Play(data)
    return data
end

local function StopAnimation(Character,data)
    local Animator = AnimationsComponent.new(Character)
    Animator:Stop(data)
    return data
end

Effects['Carry'] = {}

Effects['Carry'] = {
    ['Carry'] = function(args)
        
        PlayAnimation(args.Player.Character, 'Owner','Grab')
        PlayAnimation(args.Victim.Character, 'Victim','Grab')
        task.wait(.4)
        PlayAnimation(args.Player.Character, 'Owner','GrabIdle')
        PlayAnimation(args.Victim.Character, 'Victim','GrabIdle')

    end;
    ['UnCarry'] = function(args)
        
        StopAnimation(args.Player.Character,{
            Name = 'GrabIdle';
            Priority = Enum.AnimationPriority.Action3.Name; 
        })
        StopAnimation(args.Victim.Character,{
            Name = 'GrabIdle';
            Priority = Enum.AnimationPriority.Action3.Name; 
        })

    end
}



return Effects