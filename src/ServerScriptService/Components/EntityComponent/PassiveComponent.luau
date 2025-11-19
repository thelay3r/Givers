local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild('Shared')
local ServerComponents = ServerScriptService:WaitForChild("Components")
local Interfaces = Shared:WaitForChild("Interfaces")

local PlayerInterfaces = require(Interfaces:WaitForChild('PlayerInterfaces'))
local PassiveInterfaces = require(Interfaces:WaitForChild('PassiveInterfaces'))

local AbstractPassives = require(ServerComponents:WaitForChild('AbsctractPassives'))

type IServerPlayerComponent = PlayerInterfaces.IServerPlayerComponent
type IPassiveMethods = PassiveInterfaces.IPassiveComponents

local PassivesCache = {}

local PassiveComponent = {}

function PassiveComponent.AppendPassive(self: IServerPlayerComponent, scope : string, passiveName: string)
	
	if not PassivesCache[passiveName] then
		PassivesCache[passiveName] = require(ServerComponents.AbsctractPassives[scope][passiveName])
	end
	
	self.SessionData.Passives[passiveName] = PassivesCache[passiveName]()
	self.SessionData.Passives[passiveName].OnStart()
end

return PassiveComponent
