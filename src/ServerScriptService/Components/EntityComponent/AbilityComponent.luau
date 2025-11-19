local RunService = game:GetService('RunService')
local ServerScriptService = game:GetService('ServerScriptService')
local ServerStorage = game:GetService('ServerStorage')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')

local UtilModules = Utilities:WaitForChild('Modules')

local StatesLibrary = ServerStorage:WaitForChild('StatesLibrary')
local ServerComponents = ServerScriptService:WaitForChild('Components')
local Abilities = ServerStorage:WaitForChild('Abilities')

local ValuesInterfaces = require(Interfaces:WaitForChild('ValuesInterface'))
local AbilityInterfaces = require(Interfaces:WaitForChild('AbilityInerfaces'))
local EntityInterfaces = require(Interfaces:WaitForChild('EntityInterfaces'))

local StateManager = require(UtilModules:WaitForChild('StateManager'))
local TaskManager = require(UtilModules:WaitForChild('TaskManager'))
local TableHelper = require(UtilModules:WaitForChild('TableHelper'))
local AbilityTemplate = require(Templates:WaitForChild('Ability'))

local EntitiesComponent = require(ServerComponents:WaitForChild('EntitiesStorage'))

local Packs = {}
local Abilities = {}
local AbilitiesMethods = {}

local AbilityComponent = {}
AbilitiesMethods__index = AbilityComponent

function AbilityComponent.AddPack(self: EntityInterfaces.IEntityComponent, AbilitiesFolder: Folder)
	
	Packs[self.SessionData.UserId] = Packs[self.SessionData.UserId] or {}
	
	--[[if self.SessionData.Equipment.Weapon == "none" then
		return
	elseif self.SessionData.Equipment.Weapon == nil then
		warn("Cannot find required Pack!")
		return
	end МЕЙБИ ЭТО ЕЩЕ ПРИГОДИТЬСЯ!]]
	
	local Pack = {}
	
	for _,v: ModuleScript in pairs(AbilitiesFolder:GetDescendants()) do
		if v.Parent.Name == 'States' or v.Parent.Name == 'Behaviors' then continue end
		if v:IsA('ModuleScript') and v.Parent:IsA('Folder') then
			Pack[v.Name] = require(v)(self.SessionData.UserId)
			Pack[v.Name]['Config'] = require(v.Config)
			Pack[v.Name].Name = v.Name
		end
	end

	self.SessionData.Packs[AbilitiesFolder.Name] = Pack
	Packs[self.SessionData.UserId][AbilitiesFolder.Name] = Pack
	
	warn('Given '..AbilitiesFolder.Name..' Pack to '..self.SessionData.UserId)
	
	return Pack
end

function AbilityComponent.GetPack(self: EntityInterfaces.IEntityComponent, PackName: string)
	if not Packs[self.SessionData.UserId][PackName] then warn('Cant find required pack.') return end
	return Packs[self.SessionData.UserId][PackName]
end

function AbilityComponent.GetPacks(self: EntityInterfaces.IEntityComponent)
	if not Packs[self.SessionData.UserId] then warn("This Enity doesn't have packs") return end
	return Packs[self.SessionData.UserId]
end

function AbilityComponent.RemovePack(self: EntityInterfaces.IEntityComponent, PackName: string)
	if not Packs[self.SessionData.UserId][PackName] then warn('Cant find required pack.') return end
	Packs[self.SessionData.UserId][PackName] = nil
end

function AbilityComponent.RemoveAllPacks(self: EntityInterfaces.IEntityComponent)
	self.SessionData.Packs = {}
	Packs[self.SessionData.UserId] = {}
end

function AbilityComponent.AddAbility(self: EntityInterfaces.IEntityComponent, AbilitiesFolder: Folder, AbilityName: string)

	Abilities[self.SessionData.UserId] = Abilities[self.SessionData.UserId] or {}

	local Ability: AbilityInterfaces.IAbilityComponent = {}

	if not AbilitiesFolder:FindFirstChild(AbilityName) then return warn(AbilityName.." doesn't exist on "..AbilitiesFolder.Name) end

	local RequiredAbility = AbilitiesFolder[AbilityName]

	Ability[AbilityName] = require(RequiredAbility)(self.SessionData.UserId)
	Ability[AbilityName]['Config'] = require(RequiredAbility['Config'])

    Ability.Name = AbilityName

	self.SessionData.Abilities[AbilitiesFolder.Name] = Ability
	Abilities[self.SessionData.UserId][AbilitiesFolder.Name] = Ability

	warn('Given '..AbilityName..' Ability to '..self.SessionData.UserId)

	return Ability
end

function AbilityComponent.GetAbility(self: EntityInterfaces.IEntityComponent, Scope: string, AbilityName: string)
	if not Abilities[self.SessionData.UserId][Scope][AbilityName] then warn('Cant find required Ability.') return end
	return Abilities[self.SessionData.UserId][Scope][AbilityName]
end

function AbilityComponent.RemoveAbility(self: EntityInterfaces.IEntityComponent, Scope: string, AbilityName: string)
	if not Abilities[self.SessionData.UserId][Scope][AbilityName] then warn('Cant find required Ability.') return end
	Abilities[self.SessionData.UserId][Scope][AbilityName] = nil
end

function AbilityComponent.RemoveAllAbilities(self: EntityInterfaces.IEntityComponent)
	self.SessionData.Abilities = {}
	Abilities[self.SessionData.UserId] = {}
end

function AbilityComponent:CreateAbility(Entity : EntityPreset.IEntity)

	local self : AbilityInterfaces.IAbilitypreset = setmetatable(table.clone(AbilityTemplate()),
		{
			__index = function(t,key)
				return AbilitiesMethods[key]
			end,
		})

	self.OwnerId = Entity.SessionData.UserId

	return self
end

function AbilitiesMethods.LoadCFG(self : AbilityPreset.IAbility, CFG : {})
	for i,v in pairs(self) do
		if CFG[i] then
			self[i] = CFG[i]

		end
	end
	return self
end

function AbilitiesMethods.CloseConnection(self: AbilityInterfaces.IAbilityComponent)
	TaskManager:CancelThread(self, self.Name..'OnStart')
end

function AbilitiesMethods.SetCooldown(self: AbilityInterfaces.IAbilityComponent, increseadTime : number)
	self.Cooldown = increseadTime
	self['Config']['Cooldown'] = increseadTime
end

function AbilitiesMethods.CheckCooldown(self: AbilityInterfaces.IAbilityComponent, Additional: AbilityInterfaces.IAdditional)

	if Additional.CheckCD then
		if (os.clock() - self.LastUsed) >= self.Cooldown then return true end
	end

	return false
end

function AbilitiesMethods.CheckBlacklist(self: AbilityInterfaces.IAbilityComponent, List: {}, Additional: AbilityInterfaces.IAdditional)

	if not Additional then
		Additional = {}
	end

	if Additional.CheckCD == nil then
		Additional.CheckCD = true
	end

	local Owner: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(self.OwnerId)
	for _,v in pairs(List) do
		if Owner.SessionData.StatusEffects[v] then
			return true
		end
	end

	if Additional.CheckCD then
		if self:CheckCooldown(Additional) then return false else return true end
	else
		return false
	end

end

function AbilitiesMethods.SetAbility(self: AbilityInterfaces.IAbilityComponent, Name: string, Value: any)
	local Entity: EntityInterfaces.IEntityComponent = EntitiesComponent:Get(self.OwnerId)
	
	self[Name] = Value
	Entity.Replica:Set({Name}, Value)
end

function AbilitiesMethods.OnStart(self: AbilityInterfaces.IAbilityComponent, Additional: AbilityInterfaces.Additional)

    local AbilitiesStates = StatesLibrary['AbilitiesComponent']

	if not self.State  then
		self.State = StateManager:New(
			{
				FOLDER = AbilitiesStates;
				SECTION_NAME = 'Abilities';
				Ability = self;
				Additional = Additional;
				Method = 'OnStart';
			}
		)
	end

    self.State.args.Method = 'OnStart'
	self.State:CheckBehavior()

end

function AbilitiesMethods.OnSpecialStart(self: AbilityInterfaces.IAbilityComponent, Additional: AbilityInterfaces.Additional)

	local AbilitiesStates = StatesLibrary['AbilitiesComponent']

	if not self.State  then
		self.State = StateManager:New(
			{
				FOLDER = AbilitiesStates;
				SECTION_NAME = 'Abilities';
				Ability = self;
				Additional = Additional;
				Method = 'OnSpecialStart';
			}
		)
	end

	self.State.args.Method = 'OnSpecialStart'
	self.State:CheckBehavior()

end

function AbilitiesMethods.OnEnd(self: AbilityInterfaces.IAbilityComponent)
	if (not self.IsActive) then return end

	if (self.StartTime + self.MinDuration) > os.clock() then task.wait((self.StartTime + self.MinDuration) - os.clock()) end

	self:CloseConnection()

	self.Functions.End()

	self:SetAbility('LastUsed', os.clock())
	self:SetAbility('IsHolded', false)
	self:SetAbility('IsActive', false)

	return
end

return AbilityComponent