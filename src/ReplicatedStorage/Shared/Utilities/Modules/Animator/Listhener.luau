local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Modules = Utilities:WaitForChild('Modules')
local Interfaces = Shared:WaitForChild('Interfaces')


local EventBus = require(NetWork:WaitForChild('EventBus'))
local Handler = require(Modules:WaitForChild('Animator'):WaitForChild('Handler'))

local Listhener = {}

function Listhener.Subscribe(Animate,ClientData,Count)
	
	local CharacterBus = EventBus.new('Character')
	CharacterBus:Subscribe('OnJump',function()
		Handler.OnJump(Animate,ClientData,Count)
	end)
	
	
end


return Listhener
