--!optimize 2
--!strict

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')



local _Player = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local Interfaces = Shared:WaitForChild('Interfaces')

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local LocalPlayerComponent = require(Components:WaitForChild('LocalPlayerComponent'))


local Player = LocalPlayerComponent.New(_Player)