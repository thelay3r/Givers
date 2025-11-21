local ServerScriptService = game:GetService('ServerScriptService')
local Bricks = ServerScriptService:WaitForChild('Bricksv2')

local Data = Bricks.Data
local Abilities = Data.Abilities


local _ability = require(Abilities.Fireball2)

--[[
ability:Execute(
	{
		Name = 'Action.TriggerEvent',
		Config = {
			test = 123,
			TagName = 'OnHit12321'
		}
	}
)
]]