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


Effects['Trail'] = 
{
    ['Start'] = function(args)
        local Player = args.Player
        if not Player then return end
        local Character = Player.Character :: Model 
        if not Character then return end
        local NeedParent = Character:FindFirstChild(args.Parent)
        if not NeedParent then return end

        local scope = Assets:FindFirstChild((args.Pack) or ('Default'))
        local trailAsset = scope:FindFirstChild('Effects'):FindFirstChild('Trail'):Clone()
        trailAsset.Trail.Enabled = false

        trailAsset.Parent = workspace.Map.VFXs
        local weld = Instance.new('Weld')
        weld.Parent = trailAsset
        weld.Part0 = NeedParent
        weld.Part1 = trailAsset
        weld.C0 = CFrame.new(0,-.5,0)
        task.delay(.2, function()
            trailAsset.Trail.Enabled = true
            task.wait(1)
            trailAsset.Trail.Enabled = false
            task.wait(1)
            trailAsset:Destroy()
        end)
    end
}




return Effects