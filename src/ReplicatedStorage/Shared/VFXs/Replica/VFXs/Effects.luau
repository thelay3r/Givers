local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utilities = Modules:WaitForChild('Utilities')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TweenService = game:GetService("TweenService")

local AssetsHelper = require(Utilities:WaitForChild('AssetsHelper'))
local TaskManager = require(Utilities:WaitForChild('TaskManager'))

local Effects = {}


Effects['Trail'] = 
{
    ['Start'] = function(args)
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        if not Character then return end
        local NeedParent = Character:FindFirstChild(args.Parent)
        if not NeedParent then return end

        local packFolder = Assets:FindFirstChild((args.Pack) or ('Default'))
        local scope = packFolder:FindFirstChild((args.AbilityName))
        local vfxsScope = scope:FindFirstChild('VFXs')
        local trailAsset = vfxsScope:FindFirstChild('Trail'):Clone() :: Trail

        trailAsset.Trail.Enabled = true

        trailAsset.Parent = workspace.Map.VFXs
        local weld = Instance.new('Weld')
        weld.Parent = trailAsset
        weld.Part0 = NeedParent
        weld.Part1 = trailAsset
        weld.C0 = CFrame.new(0,-.5,0)

        TaskManager:CreateTask(Player, args.AbilityName..'Trail'..os.clock(), (args.LifeTime or 1), function(a0)  
            trailAsset.Trail.Enabled = false
            task.wait(trailAsset.Trail.Lifetime)
            trailAsset:Destroy()
        end)
    end
}




return Effects