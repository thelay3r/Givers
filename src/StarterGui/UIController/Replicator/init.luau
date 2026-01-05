local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')

local Engine = ReplicatedStorage.Shared.Components.LocalPlayerComponent

local PlayerComponent = require(Engine) 

local HUDController = require(script:WaitForChild('HUDController'))

return function(UI: typeof(StarterGui.MainUI))
	local component = PlayerComponent:GetPlayer()
	
	HUDController(UI, component)
end
