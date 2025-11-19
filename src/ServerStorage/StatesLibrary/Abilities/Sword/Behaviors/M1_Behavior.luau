local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local StatesInterfaces = require(Interfaces:WaitForChild('StatesInterfaces'))

local States = script.Parent.Parent.States

local State = require(States['M1_State'])

local M1_Behavior = {}

M1_Behavior.Test = {
	name = 'Test';
	priority = 1;
	check = function(self: StatesInterfaces.IStatesComponent)
		local Entity = self.args.Entity
		
		return true
		
	end,
	trueaction = function(self: StatesInterfaces.IStatesComponent)
		State['Test'].action(self)
	end,
	
	falseaction = function(self: StatesInterfaces.IStatesComponent)
		State['Test'].action(self)
	end,
}

return M1_Behavior
