local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')


local Bus = require(NetWork:WaitForChild('EventBus'))

local testBus = Bus.new('test')

task.delay(.5,function()
	Bus:Fire('Test',{aboba = true})
	print(Bus)
end)