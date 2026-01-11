local AnimationClipProvider = game:GetService("AnimationClipProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TweenService = game:GetService("TweenService")

local AnimationsInterfaces = require(ReplicatedStorage.Shared.Interfaces.AnimationsInterfaces)
local BackStab = require(ReplicatedStorage.Shared.Passives.Default.BackStab)
local AnimationsComponent = require(ReplicatedStorage.Shared.Utilities.Modules.AnimationsComponent)
local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local BiezeModule = require(ReplicatedStorage.Shared.Utilities.Modules.BiezeModule)
local CacheContainer = require(ReplicatedStorage.Shared.Utilities.Modules.CacheContainer)
local CameraShakeHandler = require(ReplicatedStorage.Shared.Utilities.Modules.CameraShakeHandler)
local CountHandler = require(ReplicatedStorage.Shared.Utilities.Modules.CountHandler)

local FistsFolder = Assets:WaitForChild('Fists')
local DefaultFolder = Assets:WaitForChild('Default')

local Fists = {}


local EffecteCache = CacheContainer.new()
local CameraShake = CameraShakeHandler.new()

local HitCounter = CountHandler.Create('HitCounter', 1, 4)

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

Fists['BackStab'] = {
    ['Animation'] = function(args)
        local Owner = args.Player :: Player
        local Victim = args.Victim :: Player

        local VictimCharacter = Victim.Character :: Model
        local OwnerCharacter = Owner.Character :: Model

        local VictimAnimator = AnimationsComponent.new(VictimCharacter)
        local OwnerAnimator = AnimationsComponent.new(OwnerCharacter)
        
        local AnimationsFolder = Assets.Fists.Animations.BackStab :: Folder
        local VictimAnimation = AnimationsFolder:FindFirstChild('Victim')
        local OwnerAnimation = AnimationsFolder:FindFirstChild('Owner')

        local victimAnim,Vdata = VictimAnimator:Load(VictimAnimation,{
                 Name = 'Fists_BackStabVictim';
                _Name = 'Fists_BackStabVictim';
                Priority = Enum.AnimationPriority.Action3.Name;
                Settings = {
                    Speed = 1;
                    Weight = 1;
                    FadeTime = .15;
                }
            })
        local OwnerAnim,Odata = OwnerAnimator:Load(OwnerAnimation,{
                 Name = 'Fists_BackStabOwner';
                _Name = 'Fists_BackStabOwner';
                Priority = Enum.AnimationPriority.Action3.Name;
                Settings = {
                    Speed = 1;
                    Weight = 1;
                    FadeTime = .15;
                }
            })
        OwnerAnimator:Play(Odata)
        VictimAnimator:Play(Vdata)
    end
}

Fists['BackStab']['Effects'] = function(args)
    
    local Owner = args.Player :: Player
    local Victim = args.Victim :: Player

    local VictimCharacter = Victim.Character :: Model
    local OwnerCharacter = Owner.Character :: Model

    local AssetsFolder=Assets.Fists.Effects
    local GrabEffectProtorype = AssetsFolder.BackStabGrab
    local BackStabBloodPrototype = AssetsFolder.BackStabBlood


    local GrabEffect = CacheContainer:CreateInstance('GrabFists', GrabEffectProtorype) :: BasePart
    local BloodBackStab = CacheContainer:CreateInstance('BloodFistsGrab', BackStabBloodPrototype,
    {
        'Anchored';
    }) :: BasePart

    local WeldGrab = CacheContainer:CreateInstance('WeldConstraint', Assets.Welds.WeldConstraint, {
        'Part0';
        'Part1';
    }) :: WeldConstraint
    
    local SoundPrototype = AssetsFolder.Parent.Sounds.BackStab
    local Sound = CacheContainer:CreateInstance('FistsGrabSound', SoundPrototype) :: Sound
    Sound.Parent = OwnerCharacter.PrimaryPart
    Sound:Play()
    Sound.Ended:Once(function(a0: string)  
        CacheContainer:AddInstanceToCache('FistsGrabSound', Sound)
    end)
    BloodBackStab.Anchored = true

    task.delay(25/60,function()

        GrabEffect.CFrame = OwnerCharacter['Right Arm'].CFrame - OwnerCharacter['Right Arm'].CFrame.UpVector * 1/2
        WeldGrab.Part0 = OwnerCharacter['Right Arm']

        GrabEffect.Parent = workspace.Map.VFXs
        WeldGrab.Parent = GrabEffect

        AssetsHelper.Emit(GrabEffect)
        CameraShake:ShakeByDistance({
            StartPoint = GrabEffect.Position,
            Roughness = 15,
            InTime = 0,
            OutTime = 0.5,
            MinMagnitude = 1;
            MaxMagnitude = 5;
        })
    end)

    local BloodCFG = {
            StartPoint = GrabEffect.Position,
            Roughness = 20,
            InTime = 0,
            OutTime = 0.5,
            MinMagnitude = 1;
            MaxMagnitude = 5;
        }

    task.delay(80/60, function()
        local fastCast = AssetsHelper.FastCast({
            Position = VictimCharacter['Head'].Position;
            Direction = Vector3.new(0,-5,0);
            Character = VictimCharacter;
        })
        if not fastCast then return end
        local position = fastCast.Position
        BloodBackStab.CFrame = CFrame.new(position,position+fastCast.Normal) * (CFrame.Angles(-math.rad(90),0,0))
        BloodBackStab.Orientation = Vector3.zero
        BloodBackStab.Parent = workspace.Map.VFXs
        AssetsHelper.Emit(BloodBackStab)


        CameraShake:ShakeByDistance({
            StartPoint = GrabEffect.Position,
            Roughness = 15,
            InTime = 0,
            OutTime = 0.5,
            MinMagnitude = 1;
            MaxMagnitude = 3;
        })

    end)
    task.delay(105/60, function()
        CameraShake:ShakeByDistance(BloodCFG)
        AssetsHelper.Emit(BloodBackStab)
    end)
    task.delay(130/60, function()
        CameraShake:ShakeByDistance(BloodCFG)
        AssetsHelper.Emit(BloodBackStab)


        task.delay(3, function()
            CacheContainer:AddInstanceToCache('GrabFists', GrabEffect)
            CacheContainer:AddInstanceToCache('BloodFistsGrab', BloodBackStab)
        end)
    end)
end

Fists['M1']['Run'] = function(args)
        local Player = args.Player
        local Character = Player.Character :: Model
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

        local Animator = AnimationsComponent.new(Character) :: AnimationsInterfaces.IAnimationsComponent
        local NeededPack = Assets:FindFirstChild('Fists'):FindFirstChild('Animations')
        local Animation = NeededPack:FindFirstChild('RunAttack')

        local animation,_data = Animator:Load(Animation, {
                Name = 'Fists_Run';
                _Name = 'Fists_Run';
                Priority = Enum.AnimationPriority.Action2.Name;
                Settings = {
                    Speed = 1;
                    Weight = 1;
                    FadeTime = .15;
                }
            })
        Animator:Play(_data)
        print('Jump!!!!!')
    end

Fists['M1']['Jump'] = function(args)
        local Player = args.Player
        local Character = Player.Character :: Model
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

        local Animator = AnimationsComponent.new(Character) :: AnimationsInterfaces.IAnimationsComponent
        local NeededPack = Assets:FindFirstChild('Fists'):FindFirstChild('Animations')
        local Animation = NeededPack:FindFirstChild('JumpAttack')

        local animation,_data = Animator:Load(Animation, {
                Name = 'Fists_Jump';
                _Name = 'Fists_Jump';
                Priority = Enum.AnimationPriority.Action2.Name;
                Settings = {
                    Speed = 1;
                    Weight = 1;
                    FadeTime = .15;
                }
            })
        Animator:Play(_data)
        
    end

Fists['M1']['JumpLocale'] = function(args)
    local Player = args.Player
    local Character = Player.Character :: Model
    local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

    local Animator = AnimationsComponent.new(Character) :: AnimationsInterfaces.IAnimationsComponent
    local NeededPack = Assets:FindFirstChild('Fists'):FindFirstChild('Animations')
    local Animation = NeededPack:FindFirstChild('JumpAttack')

    local Speed = 75
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


local function HitAnimation(Victim: Model,Owner: Model)
    local VAnimator= AnimationsComponent.new(Victim)
    local Animation = Assets.Default.Animations.Hits[HitCounter()]

    local _,data = VAnimator:Load(Animation,
    {
        Name = 'Hit';
        _Name = 'HitFists'..HitCounter();
        Priority = Enum.AnimationPriority.Action2.Name;
        Settings = {
            FadeTime = .1;
            Weight = 1;
            Speed = 1;
        }
    })
    VAnimator:Play(data)
    HitCounter:Increment()
end

Fists['Hit'] = {
    ['Hit'] = function(args)
        local Player = args.Player :: Player
        local Character = Player.Character :: Model
        local RootPart = Character:FindFirstChild('HumanoidRootPart') :: BasePart

        

        local Vfx = FistsFolder:FindFirstChild('Effects')
        local HighlightPrototype = DefaultFolder:FindFirstChild('Effects'):FindFirstChild('Hit') :: Highlight
        local Hit = EffecteCache:CreateInstance('HitFists', Vfx:FindFirstChild('Hit')) :: BasePart
        local WeldProtorype = Assets.Welds.WeldConstraint
        local weld = EffecteCache:CreateInstance('Welds', WeldProtorype) :: WeldConstraint
        local Sound = EffecteCache:CreateInstance('FistHit'..args.Combo, FistsFolder:FindFirstChild('Sounds'):FindFirstChild('HitsSound')[args.Combo]) :: Sound
        local Highlight = EffecteCache:CreateInstance('Hit Highlight', HighlightPrototype, 
        {
            'OutlineTransparency';
            'FillTransparency';
        })

        Hit.CFrame = RootPart.CFrame
        weld.Part0 = RootPart
        weld.Part1 = Hit
        weld.Parent = Hit
        Hit.Parent = workspace.Map.VFXs

        Highlight.Parent = Character
        local HighlightTween = TweenService:Create(Highlight, TweenInfo.new(.2), {
            OutlineTransparency = 1;
            FillTransparency = 1;
        })
        HighlightTween:Play()
        HighlightTween.Completed:Once(function()  
            EffecteCache:AddInstanceToCache('Hit Highlight', Highlight)
        end)

        AssetsHelper.Emit(Hit)
        Sound.Parent = RootPart
        Sound:Play()

        HitAnimation(Character)

        Sound.Ended:Once(function()  
            EffecteCache:AddInstanceToCache('FistHit'..args.Combo, Sound)
        end)
        

        task.delay(1, function()
            EffecteCache:AddInstanceToCache('HitFists', Hit)
            EffecteCache:AddInstanceToCache('Welds', weld)
        end)

    end
}



return Fists