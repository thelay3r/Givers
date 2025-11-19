local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))

local M1_State = {}

M1_State.Test = {
	trueaction = function(self: StatesInterfaces.IStatesComponent)
		print(self.args)
	end,
	
	falseaction = function(self: StatesInterfaces.IStatesComponent)
		print(self.args)
	end,
}

return M1_State
