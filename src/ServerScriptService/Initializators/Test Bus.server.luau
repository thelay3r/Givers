local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')


local EventBus = require(NetWork:WaitForChild('EventBus'))

local TestBus = EventBus.new('test')

TestBus:Once('test',function()
	
end)

TestBus:Subscribe('test1',function()
	
end)

local t: Humanoid

t.Jumping:Connect(function()
	TestBus:Fire('Jump')
end)