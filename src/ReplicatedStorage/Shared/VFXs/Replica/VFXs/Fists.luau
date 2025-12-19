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
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local Fists = {}



Fists['Idle'] = {
    ['Equip'] = function(args)
        local Player = args.Player
        local Character = Player.Character

        local Animator = AnimationsComponent.new(Character)
        local NeededPack = Assets:FindFirstChild('Fists'):FindFirstChild('Animations')
        local IdleAnimation = NeededPack:FindFirstChild('Idle')
        local EquipAnimation = NeededPack:FindFirstChild('Equip')

        local _animation,_data = Animator:Load(IdleAnimation,{
			Name = 'Idle';
			_Name = 'Fists'..'Idle';
			Priority = Enum.AnimationPriority.Idle.Name;
			Settings = {
            Speed = 1;
            Weight = 1;
            FadeTime = .1;
        }})

        local _animationEquip,_data2 = Animator:Load(EquipAnimation,{
			Name = 'Equip';
			_Name = 'Fists'..'Equip';
			Priority = Enum.AnimationPriority.Action.Name;
			Settings = {
            Speed = 1;
            Weight = 1;
            FadeTime = .1;
        }})
        Animator:Play(_data2)
        Animator:Play(_data)

    end;
    ['Unequip'] = function(args)
        local Player = args.Player
        local Character = Player.Character

        local Animator = AnimationsComponent.new(Character) :: AnimationsInterfaces.IAnimationsComponent
        Animator:Play({
            Name = 'Idle';
            _Name = 'DefaultIdle';
            Priority = Enum.AnimationPriority.Idle.Name;
        })
        Animator:Stop({
            Name = 'Equip';
            _Name = 'FistsEquip';
            Priority = Enum.AnimationPriority.Action.Name;
        })
    end;
}

Fists['M1'] = {
    ['OnStart'] = function(args)
        print(args)
        local Player = args.Player
        local Character = Player.Character
        local Animator = AnimationsComponent.new(Character) :: AnimationsInterfaces.IAnimationsComponent
        local NeededPack = Assets:FindFirstChild('Fists'):FindFirstChild('Animations'):WaitForChild('M1')
        local Animation = NeededPack[args.Combo]
        local animation,_data = Animator:Load(Animation, {
            Name = 'M1';
            _Name = 'Fists_M1'..args['Combo'];
            Priority = Enum.AnimationPriority.Action2.Name;
            Settings = {
                Speed = 1;
                Weight = 1;
                FadeTime = .15;
            }
        })
        Animator:Play(_data)

    end,
}

return Fists