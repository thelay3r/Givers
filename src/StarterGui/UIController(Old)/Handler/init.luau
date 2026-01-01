local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

local LocalPlayer = game.Players.LocalPlayer
local PlayersScripts = LocalPlayer.PlayerScripts

--[[local HotbarController = require(script.HotbarController)
local TopBarController = require(script.TopBarController)]]

local plr = game.Players.LocalPlayer

--[[return function(UI: typeof(StarterGui.Interface))
	HotbarController(UI)
	TopBarController(UI)
end]]

return function (UI: typeof(StarterGui.New))
	for i, v in pairs(script:GetChildren()) do
		require(v)(UI)
	end
end
