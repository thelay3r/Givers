local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Templates = Shared:WaitForChild('Templates')


local ReplicaClient = require(NetWork:WaitForChild('ReplicaClient'))

local ClientDataTemplate = require(Templates.ClientData)

local ILocalPlayer = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))

local ClientDataComponent = {}

local Token = 'PlayerData'
local Loaded = false

function ClientDataComponent.LoadClientData(self: ILocalPlayer.IClientPlayerComponent)
	return ClientDataTemplate()
end

function ClientDataComponent.ReplicaInit(self: ILocalPlayer.IClientPlayerComponent)
	ReplicaClient.OnNew(Token,function(replica)
		self.Replica = replica
		Loaded = true
		
		warn('Replica started!')
	end)
	ReplicaClient.RequestData()
	while (not Loaded) do task.wait(1/10) end

	self.Replica:OnChange(function(Method,Path,new,old)
	end)
	
	
	return self
end
	
return ClientDataComponent
