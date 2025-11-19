local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild('Shared')
local ServerComponents = ServerScriptService:WaitForChild("Components")
local Interfaces = Shared:WaitForChild("Interfaces")

local PassiveInterfaces = require(Interfaces:WaitForChild('PassiveInterfaces'))

type IPassiveComponent = PassiveInterfaces.IPassiveComponents

local AbstractAbilities = {}

function AbstractAbilities.OnStart()
end

function AbstractAbilities.OnEnd()
end

function AbstractAbilities:SetupData(level: number)
	self.Level = level
end

function AbstractAbilities.New(scope : string, passiveName: string):IPassiveComponent
	local self = setmetatable({}, {__index = AbstractAbilities})
	return self
end

return AbstractAbilities
