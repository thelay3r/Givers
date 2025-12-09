local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TweenService = game:GetService("TweenService")

local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local Effects = {}


Effects['Normal'] = 
{
    ['Start'] = function(args)
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        if not Character then return end

        local neededFolder = Assets:FindFirstChild('Movement')
        local neededScope = neededFolder:FindFirstChild('Dash')
        local soundFolder = neededScope:FindFirstChild('Sounds')
        local VfxFodler = neededScope:FindFirstChild('VFXs')
        local Effect = VfxFodler:FindFirstChild('dashEffect'):Clone() :: BasePart
        local sound = soundFolder:FindFirstChild('Dash'):Clone() :: Sound

        local cast = AssetsHelper.FastCast(
            {
                Position = Character.PrimaryPart.Position;
                Direction = Vector3.new(0,-5,0);
                Character = Character;
            })
        
        sound.Parent = Character.PrimaryPart
        AssetsHelper.PlaySound(sound)

        if not cast then return end
        Effect.CFrame = CFrame.new(cast.Position,cast.Position+cast.Normal) * CFrame.Angles(math.rad(90), 0, 0) * CFrame.Angles(math.pi, 0, 0)
        Effect.Anchored = true
        Effect.Parent = workspace
        AssetsHelper.Emit(Effect)
            
        
    end
}

Effects['Cancel'] = 
{
    ['Start'] = function(args)
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        if not Character then return end

        local neededFolder = Assets:FindFirstChild('Movement')
        local neededScope = neededFolder:FindFirstChild('Dash')
        local soundFolder = neededScope:FindFirstChild('Sounds')
        local VfxFodler = neededScope:FindFirstChild('VFXs')
        local Effect = VfxFodler:FindFirstChild('dashEffect'):Clone() :: BasePart
        local sound = soundFolder:FindFirstChild('Dash'):Clone() :: Sound

            
        
    end
}




return Effects