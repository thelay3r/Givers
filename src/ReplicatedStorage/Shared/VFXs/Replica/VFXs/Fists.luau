local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TweenService = game:GetService("TweenService")

local AnimationsInterfaces = require(ReplicatedStorage.Shared.Interfaces.AnimationsInterfaces)
local AnimationsComponent = require(ReplicatedStorage.Shared.Utilities.Modules.AnimationsComponent)
local Animator = require(ReplicatedStorage.Shared.Utilities.Modules.Animator)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local BiezeModule = require(ReplicatedStorage.Shared.Utilities.Modules.BiezeModule)
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
        print(Animator,'Tag 1')
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
         Animator:Play({
            Name = 'Equip';
            Priority = Enum.AnimationPriority.Action.Name;
            Settings = {
                Speed = -1;
                FadeTime = 0;
            }
         })
    end;
}



Fists['Block'] = {
    ['OnStart'] = function(args)

        local Player = args.Player
        local Character = Player.Character
        local Animator = AnimationsComponent.new(Character)
        local NeededPack = Assets:FindFirstChild('Fists'):FindFirstChild('Animations')
        local BlockFolder = NeededPack:FindFirstChild('Block')

        local IdleAnimation = BlockFolder:findFirstChild('Idle')
        local EquipAnimation = BlockFolder:FindFirstChild('Action')
        
        local _animation,_data = Animator:Load(IdleAnimation,{
			Name = 'Block_Idle';
			_Name = 'Fists_BlockIdle';
			Priority = Enum.AnimationPriority.Action.Name;
			Settings = {
            Speed = 1;
            Weight = 1;
            FadeTime = .1;
        }})

        local _animationEquip,_data2 = Animator:Load(EquipAnimation,{
			Name = 'Block';
			_Name = 'Fists_Block';
			Priority = Enum.AnimationPriority.Action2.Name;
			Settings = {
            Speed = 1;
            Weight = 1;
            FadeTime = .1;
        }})
        Animator:Play(_data2)
        Animator:Play(_data)
    end,
        ['OnStop'] = function(args)

        local Player = args.Player
        local Character = Player.Character
        local Animator = AnimationsComponent.new(Character)
        local NeededPack = Assets:FindFirstChild('Fists'):FindFirstChild('Animations')
        local BlockFolder = NeededPack:FindFirstChild('Block')

        Animator:Stop({
            Name = 'Block_Idle';
            _Name = 'Fists_BlockIdle';
            Priority = Enum.AnimationPriority.Action.Name;
        })
        Animator:Stop({
            Name = 'Block';
            _Name = 'Fists_Block';
            Priority = Enum.AnimationPriority.Action2.Name;
        })
    end
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

Fists['Critical'] = {
    ['Start'] = function(args)
        local Player = args.Player
        local Character = Player.Character :: Model
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

        local Animator = AnimationsComponent.new(Character) :: AnimationsInterfaces.IAnimationsComponent
        local NeededPack = Assets:FindFirstChild('Fists'):FindFirstChild('Animations')
        local Animation = NeededPack:FindFirstChild('Critical')

        local animation,_data = Animator:Load(Animation, {
                Name = 'Critical';
                _Name = 'Fists_Critical';
                Priority = Enum.AnimationPriority.Action2.Name;
                Settings = {
                    Speed = 1;
                    Weight = 1;
                    FadeTime = .15;
                }
            })
        Animator:Play(_data)
        

        local Speed = 45
        local BodyVelocity = AssetsHelper.CreateBodyVelocity({
            Instance = {
                Parent = RootPart;
                Velocity = RootPart.CFrame.LookVector * Speed;
                MaxForce = Vector3.one * 15000 * Vector3.new(1,0,1);
                P = 15000;

            };
            Settings = {
                DestroyTime = .3;
            }
        })


        for i=1,30 do 
            local t = i/30
            local lerp = BiezeModule.lerp(1,0,t,Enum.EasingStyle.Quad,Enum.EasingDirection.Out) * Speed
            BodyVelocity.Velocity = RootPart.CFrame.LookVector * lerp
            task.wait(1/60)
		end

    end
}

return Fists