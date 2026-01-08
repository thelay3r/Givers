local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')

local TableHelper = require(Modules:WaitForChild('TableHelper'))

local StateRegist = {}



local Cache = {}


function StateRegist.Regist(name: string)
	if Cache[name] then return Cache[name] end
	local state = TableHelper:DeepTableClone(require(script:FindFirstChild(name)))
	
	return state
end


return StateRegist
