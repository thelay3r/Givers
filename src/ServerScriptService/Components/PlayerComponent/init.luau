--!optimize 2
--!strict

local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')


local Templates = Shared:WaitForChild('Templates')
local Interfaces = Shared:WaitForChild("Interfaces")

local PlayerInterfaces = require(Interfaces:WaitForChild('PlayerInterfaces'))

local _SessionData = require(Templates:WaitForChild('SessionData'))
local Components = ServerScriptService.Components

local EntityComponent = require(Components.EntityComponent)

local LoadedComponents: {[string]: any} = {}

for _, component in pairs(script:GetChildren()) do
	LoadedComponents[component.Name] = require(component) :: any
end

local _TableHelper = require(Modules:FindFirstChild('TableHelper'))


local PlayerComponent = {}


function PlayerComponent.new(_player: Player): PlayerInterfaces.IServerPlayerComponent
	
	local entity = EntityComponent.new()
	
	local self = setmetatable({}, {__index = function(_, i)
		for _, component in pairs(LoadedComponents) do
			if (component[i]) then return component[i] end
		end
		
		if (entity[i]) then return entity[i] end
		return PlayerComponent[i]
	end})
	self.Instance = _player
	self.Profile = self:LoadProfile()
	self.SessionData = self:LoadSession()
	self.SessionData.UserId = self.Instance.UserId
	
	self:SetupCharacter()
	self:LoadReplica()
	
	local Character : Model? = self.Instance.Character
	local _Id: number = if Character then Character:GetAttribute('Id') :: number else 0


	self:AppendPassive("Default", "Test")
	EntityComponent.AddToList(_Id,self)
	self:AppendAbility('Default','Equip')
	print(self)
	return self :: any --:: PlayerInterfaces.IServerPlayerComponent
end

return PlayerComponent
