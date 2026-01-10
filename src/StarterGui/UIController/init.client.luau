local StarterGui = game:GetService('StarterGui')

local PlayerGUI = game.Players.LocalPlayer.PlayerGui

local Components = script.Parent:WaitForChild('Components')

local mainUI = PlayerGUI:WaitForChild('MainUI')
local sampleUI = StarterGui:WaitForChild('MainUI')

--local Utilities = require(Components:WaitForChild('UIUtilities'))

--local SignalComponent = require(ReplicatedStorage:WaitForChild('Components'):WaitForChild('SignalComponent')) 

repeat task.wait(.1) until #mainUI:GetDescendants() >= #sampleUI:GetDescendants()

require(script.Replicator)(mainUI)

--Utilities:AutoScaleStroke(mainUI)
--Utilities:AutoScale(mainUI)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

