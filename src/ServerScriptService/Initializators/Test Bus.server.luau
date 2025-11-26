local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')



local AbilityHandler = require(ServerScriptService:WaitForChild('Components'):WaitForChild('AbilityHandler'))



-- local t = AbilityHandler.new('test',123,{})
-- AbilityHandler.OnStart('test')

local t = AbilityHandler.createByName('Default','Equip')
t:BindToEntity('Equip', 123)
print(t)
t:Destroy()
print(t)


