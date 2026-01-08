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



Effects['BodyVelocity'] = 
{
    ['Start'] = function(args)
        
    end
}




return Effects