local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local EntityInterfaces = require(Interfaces:WaitForChild("EntityInterfaces"))

type IEntityComponent = EntityInterfaces.IEntityComponent

local LoadedComponents = {}

for _, component in pairs(script:GetChildren()) do
	LoadedComponents[component.Name] = require(component)
end

local EntityComponent = {}
EntityComponent.__index = function(t, i)
	for _, component in pairs(LoadedComponents) do
		if (component[i]) then return component[i] end
	end
	
	return EntityComponent[i]
end

function EntityComponent.new(): IEntityComponent
	local self: IEntityComponent = setmetatable({
		
	}, EntityComponent)
	
	self.SessionData = self:LoadSession()
	--self.SessionData.Packs[self.SessionData.Equipment.Weapon] = self:SetupPack()
	
	return self
end

return EntityComponent
