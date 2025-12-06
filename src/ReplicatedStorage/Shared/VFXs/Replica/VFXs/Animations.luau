local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TaskManager = require(Modules:WaitForChild('TaskManager'))
local AnimationsComponent = require(Modules:WaitForChild('AnimationsComponent'))

local KeyCode = {}

local function RunStart(args)
    local Player: Player = args.Player
    if not Player then return end
    local Character = Player.Character 
    if not Character then return end
    local animator = AnimationsComponent.new(Character)
    if not animator then return end

    local Humanoid = Character:FindFirstChildOfClass('Humanoid')
    if not Humanoid then return end

    local animationAsset: Animation = Assets:FindFirstChild((args.Pack) or ('Default')):FindFirstChild('Animations'):WaitForChild('Run')
    local _,data = animator:Load(animationAsset,
        {
            Name = "Run",
            Priority = Enum.AnimationPriority.Action.Name,
            _Name = (args.Pack..'Run') or ('DefaultRun'),
            Settings =
            {
                ['Speed'] = 1,
                ['Weight'] = 1,
                ['FadeTime'] = .3,
            } 
        })
    animator:Play(data)
    TaskManager:CreateTask(Player, 'RunAccelration', 0, function(a0)
        for i=1,10 do 
            animator:AdjustSpeed(data,(math.clamp(Humanoid.WalkSpeed / 24, .3, 2)))
            task.wait(1/10)
        end
    end)
end

local function RunStop(args)
    local Player: Player = args.Player
    if not Player then return end
    local Character = Player.Character 
    if not Character then return end
    local animator = AnimationsComponent.new(Character)
    if not animator then return end

    TaskManager:CancelTask(Player, 'RunAccelration')
    animator:Stop(
        {
            Name = "Run",
            _Name = (args.Pack..'Run') or ('DefaultRun'),
            Priority = Enum.AnimationPriority.Action.Name,

        })
end

local function DashStart(args)

    local Player: Player = args.Player
    if not Player then return end
    local Character = Player.Character 
    if not Character then return end
    local animator = AnimationsComponent.new(Character)
    if not animator then return end

    local Humanoid = Character:FindFirstChildOfClass('Humanoid')
    if not Humanoid then return end

    local PackFolder = Assets:FindFirstChild((args.Pack) or ('Default'))
    if not PackFolder then return end
    local Defis = (args.DashConfig.MainDirection) or ('Front')
    local AnimationNedeed = 'Dash_'..Defis

    local animationAsset: Animation = PackFolder:FindFirstChild('Animations')[AnimationNedeed]
    local _,data = animator:Load(animationAsset,
        {
            Name = 'Dash',
            Priority = Enum.AnimationPriority.Action3.Name,
            _Name = (AnimationNedeed) or ('DefaultDash'),
            Settings =
            {
                ['Speed'] = 1,
                ['Weight'] = 1,
                ['FadeTime'] = .05,
            } 
        })
    animator:Play(data)
end

local function DashCancel(args)
    print(args)
    local Player: Player = args.Player
    if not Player then return end
    local Character = Player.Character 
    if not Character then return end
    local animator = AnimationsComponent.new(Character)
    if not animator then return end

    local Humanoid = Character:FindFirstChildOfClass('Humanoid')
    if not Humanoid then return end

    local PackFolder = Assets:FindFirstChild((args.Pack) or ('Default'))
    if not PackFolder then return end

    local animationAsset: Animation = PackFolder:FindFirstChild('Dash'):FindFirstChild('Animations'):FindFirstChild('Cancels')['Cancel']
    local _,data = animator:Load(animationAsset,
        {
            Name = 'DashCancel',
            Priority = Enum.AnimationPriority.Action3.Name,
            _Name = 'DashCancel',
            Settings =
            {
                ['Speed'] = 1,
                ['Weight'] = 1,
                ['FadeTime'] = .05,
            } 
        })
    print('Alo')
    animator:Play(data)
    animator:Stop(
        {
            Name = 'Dash';
            Priority = Enum.AnimationPriority.Action3.Name;
        })
end

local AnimationsVfxs = {}
AnimationsVfxs['Run'] = 
{
    ['Start'] = function(args)
        RunStart(args)
    end,
    ['Stop'] = function(args)
       RunStop(args)
    end,
}


AnimationsVfxs['Dash'] = 
{
    ['Start'] = function(args)
        DashStart(args)
    end,
}

AnimationsVfxs['DashCancel'] = 
{
    ['Start'] = function(args)
        DashCancel(args)
    end,
}


return AnimationsVfxs