local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utilities = Modules:WaitForChild('Utilities')

local TableHelper = require(Utilities:WaitForChild('TableHelper'))

local StateRegist = {}



local Cache = {}


function StateRegist.Regist(name: string)
	if Cache[name] then return Cache[name] end
	local state = TableHelper:DeepTableClone(require(script:FindFirstChild(name)))
	
	return state
end


return StateRegist
