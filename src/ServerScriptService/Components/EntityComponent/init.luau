local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')

local flatten = require(ReplicatedStorage.Packages[".pesde"]["littensy_charm-sync@0.3.0"]["charm-sync"].src.flatten)
local nicknames = require(ReplicatedStorage.Shared.Utilities.Modules.Fusion.Utility.nicknames)
local EntityInterfaces = require(Interfaces:WaitForChild("EntityInterfaces"))

type IEntityComponent = EntityInterfaces.IEntityComponent

local LoadedComponents = {}
local Entities = {}

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

function EntityComponent.GetEntity(Id)
	return Entities[tostring(Id)]
end

function EntityComponent.AddToList(Id,Entity)
	if Entities[Id] then return end
	Entities[Id] = Entity
	print(Entities)
end

function EntityComponent.RemoveFromList(Id)
	if not Entities[Id] then return end
	Entities[Id] = nil
end

function EntityComponent.new(): IEntityComponent
	local self  = setmetatable({
		
	}, EntityComponent)
	
	self.SessionData = self:LoadSession()
	--self.SessionData.Packs[self.SessionData.Equipment.Weapon] = self:SetupPack()

	return self
end

return EntityComponent
