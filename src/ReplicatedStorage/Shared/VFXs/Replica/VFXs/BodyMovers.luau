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



Effects['BodyVelocity'] = 
{
    ['Start'] = function(args)
        
    end
}




return Effects