local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local StarterGui = game:GetService('StarterGui')

local PlayerGUI = game.Players.LocalPlayer.PlayerGui

local Components = script.Parent:WaitForChild('Components')
local Prototypes = Components.Prototypes

local mainUI = PlayerGUI:WaitForChild('New')
local sampleUI = StarterGui:WaitForChild('New')

local ButtonPrototype = require(Prototypes:WaitForChild('HotbarButton'))
local ButtonComponent = require(Components:WaitForChild('UIButtonComponent'))
local FrameComponent = require(Components:WaitForChild('UIFrameComponent'))

local Utilities = require(Components:WaitForChild('HotbarUtilities'))

--local SignalComponent = require(ReplicatedStorage:WaitForChild('Components'):WaitForChild('SignalComponent')) 

repeat task.wait(.1) until #mainUI:GetDescendants() >= #sampleUI:GetDescendants()

require(script.Handler)(mainUI)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

Utilities:AutoScaleStroke(mainUI)