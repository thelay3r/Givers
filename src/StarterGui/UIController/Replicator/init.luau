local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

local LocalPlayer = game.Players.LocalPlayer
local PlayersScripts = LocalPlayer.PlayerScripts
local Engine = ReplicatedStorage.Components.PlayerComponent

local PlayerComponent = require(Engine) 

local StoreController = require(script:WaitForChild('StoreController'))



return function(UI: typeof(StarterGui.MainUI))
	local component = PlayerComponent:GetPlayer()
	
	StoreController(UI, component)
end
