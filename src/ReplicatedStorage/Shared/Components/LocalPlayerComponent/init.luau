local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Interfaces = Shared:WaitForChild('Interfaces')

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local DefaultInputs = require(script.ActionComponent.DefaultInput)
local EventBus = require(NetWork:WaitForChild('EventBus'))
local LoadedComponents = {}
local PlayerComponent = nil

for _, component in pairs(script:GetChildren()) do
	LoadedComponents[component.Name] = require(component)
end

local LocalPlayerComponent = {}

function LocalPlayerComponent.New(player: Player): LocalPlayerInterfaces.IClientPlayerComponent
	local self = setmetatable({}, {__index = function(t, i)
		for _, component in pairs(LoadedComponents) do
			if (component[i]) then return component[i] end
		end
		return LocalPlayerComponent[i]
	end}) :: any & LocalPlayerInterfaces.IAbilityMethods
	
	self.Instance = player
	self.ClientData = self:LoadClientData()
	self.ClientData.Controls = DefaultInputs
	self.Buses = 
		{
			['Main'] = EventBus.new('Player');
			['Character'] = EventBus.new('Character');
			
		}
	
	
	self:ReplicaInit()
	self:SetupCharacter()
	
	self:UpdateControls(self.ClientData.Controls)
	self:ReplicateKeys()
	self.CreateSmoothShiftLock(self)
	self:InitClientVFX()
	self:InitCamera()
	self:SharePlayer()
	
	PlayerComponent = self
	
	print(self)
	return self
end

function LocalPlayerComponent:GetPlayer(): LocalPlayerInterfaces.IClientPlayerComponent
	return PlayerComponent
end

return LocalPlayerComponent
