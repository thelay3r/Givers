local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local Templates = Shared:WaitForChild('Templates')
local Utilities = Shared:WaitForChild('Utilities')
local Interfaces = Shared:WaitForChild('Interfaces')

local Modules = Utilities:WaitForChild('Modules')

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))

type IClientPlayerComponent = LocalPlayerInterfaces.IClientPlayerComponent
type ILocalAbility = AbilityInterfaces.ILocalAbilityComponent

local ClientAbility = require(Modules:WaitForChild('ClientAbilities'))

local ClientAbilityComponent = {}

local Player: IClientPlayerComponent

function ClientAbilityComponent.ClearAbilities(self: IClientPlayerComponent)
	local newControls = {}
	
	for _, control in pairs(self.ClientData.Controls) do
		if (control.Name == 'Ability') then continue end
		table.insert(newControls, control)
	end
	
	table.clear(self.ClientData.Controls)
	self.ClientData.Controls = newControls
	
	self:UpdateControls(self.ClientData.Controls)
	
	table.clear(self.ClientData.Abilities)
end

function ClientAbilityComponent.ClearAbility(self: IClientPlayerComponent, ability: ILocalAbility)
	self.ClientData.Abilities[ability] = nil
end

function ClientAbilityComponent.AddAbility(self: IClientPlayerComponent, ability: ILocalAbility)
	table.insert(self.ClientData.Abilities, ability)
end

function ClientAbilityComponent.AddAbilities(self: IClientPlayerComponent, abilities: {ILocalAbility})
	for _, ability in pairs(abilities) do
		self:AddAbility(ability)
		table.insert(self.ClientData.Controls, 
			{ 
				Name = 'Ability', 
				Code = ability.Key,
				State = ability.State,
				Additional = { Name = ability.Name }
				
			})
	end
end

function ClientAbilityComponent.UpdateAbilities(self: IClientPlayerComponent, abilities: {ILocalAbility})
	self:ClearAbilities()
	self:AddAbilities(abilities)
end

function ClientAbilityComponent.GetPack(self: IClientPlayerComponent,packName)
	return ClientAbility.GetPack(self, packName)
end

function ClientAbilityComponent.LoadMovement(self: IClientPlayerComponent)
	Player = self
	local ClientData = self.ClientData
	ClientAbility.AddPack(self,Shared.Abilities.Movement)
	print(ClientData)
end

function ClientAbilityComponent:GetPlayer()
	return Player
end

return ClientAbilityComponent
