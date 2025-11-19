local ServerScriptService = game:GetService('ServerScriptService')
local Components = ServerScriptService:WaitForChild('Components')

local PlayerComponent = require(Components:WaitForChild('PlayerComponent'))

local PlayerComponentBuilder = {}
PlayerComponentBuilder.__index = PlayerComponentBuilder

function PlayerComponentBuilder.new()
	local self = setmetatable({
		PlayerComponents = {},
	}, PlayerComponentBuilder)
	
	return self
end

function PlayerComponentBuilder.CreateComponent(self, player: Player)
	local component = PlayerComponent.new(player)
	self.PlayerComponents[player.UserId] = component
	
	
	
	return component
end

function PlayerComponentBuilder.GetComponent(self, player: Player)
	return self.PlayerComponents[player.UserId]
end

function PlayerComponentBuilder.RemoveComponent(self, player: Player)
	table.clear(self.PlayerComponents[player.UserId])
	self.PlayerComponents[player.UserId] = nil
end

return PlayerComponentBuilder.new()