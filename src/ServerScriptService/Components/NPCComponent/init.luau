local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local HttpService = game:GetService('HttpService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = ServerScriptService:WaitForChild('Components')
local Interfaces = Shared:WaitForChild('Interfaces')

local Utilites = Shared:WaitForChild('Utilities')
local NetWork = Utilites:WaitForChild('NetWork')
local Modules = Utilites:WaitForChild('Modules')

local VFXReplica = require(NetWork:WaitForChild('VfxReplica'))
local Replicator = require(NetWork:WaitForChild('Replicator'))
local EntityComponent = require(Components:WaitForChild('EntityComponent'))
local EntitiesComponent = require(Components:WaitForChild('EntitiesStorage'))
local TaskManager = require(Modules:WaitForChild('TaskManager'))

local NPCInterfaces = require(Interfaces:WaitForChild('NPCInterfaces'))
local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))

type IEntity = EntityInterfaces.IEntityComponent

local LoadedComponents = {}

for _, component in pairs(script:GetChildren()) do
	LoadedComponents[component.Name] = require(component)
end

local NPCComponent = {}

function NPCComponent.Destroy(self: NPCInterfaces.INPCComponent)
	TaskManager:CancelAllTasks(self)
	TaskManager:CancelAllThreads(self)
	
	for _, sub in pairs(self.SessionData) do
		if type(sub) == "table" then
			table.clear(sub) 
		end
	end
	table.clear(self.SessionData)
	table.clear(self)
end

function NPCComponent.New(Model): NPCInterfaces.INPCComponent
	
	local Id = HttpService:GenerateGUID(false)
	
	local entity = EntityComponent.new()

	local self = setmetatable({} :: any, {
		__index = function(_, i)
			for _, component in pairs(LoadedComponents) do
				if (component[i]) then return component[i] end
			end

			if (entity[i]) then return entity[i] end
			return NPCComponent[i]
		end
	}) :: NPCInterfaces.INPCComponent
	
	self.SessionData = self:LoadSession()
	self.SessionData.UserId = Id
	self:SetupCharacter(Model)
	
	local Character : Model? = self.Instance.Character
	local _Id: number = if Character then Character:GetAttribute('Id') :: number else 0
	EntityComponent.AddToList(_Id,self)
	task.wait(1/10)
	Replicator:GetRemote('BindableGlobal'):BindableFire('SetUp', self.SessionData.UserId)

	

	return self
	
end

return NPCComponent
