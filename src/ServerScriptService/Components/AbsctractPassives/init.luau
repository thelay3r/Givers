local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild('Shared')
local ServerComponents = ServerScriptService:WaitForChild("Components")
local Interfaces = Shared:WaitForChild("Interfaces")

local PassiveInterfaces = require(Interfaces:WaitForChild('PassiveInterfaces'))

type IPassiveComponent = PassiveInterfaces.IPassiveComponents

local AbsctractPassives = {}

function AbsctractPassives.OnStart()
end

function AbsctractPassives:SetupData(level: number)
	self.Level = level
end

function AbsctractPassives.New(scope : string, passiveName: string):IPassiveComponent
	local self = setmetatable({}, {__index = AbsctractPassives})
	return self
end

return AbsctractPassives
