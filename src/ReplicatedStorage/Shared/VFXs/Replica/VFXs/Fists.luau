local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local VFXs = Shared:WaitForChild('VFXs')
local Assets = VFXs:WaitForChild('Assets')

local TweenService = game:GetService("TweenService")

local AssetsHelper = require(ReplicatedStorage.Shared.Utilities.Modules.AssetsHelper)
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local Fists = {}


Fists['Idle'] = {
    ['OnStart'] = function(args)

    end;
    ['OnStop'] = function(args)
        
    end;
}


return Fists