local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Components = Shared:WaitForChild('Components')
local Interfaces = Shared:WaitForChild('Interfaces')

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))
local ToolInterfaces = require(Interfaces:WaitForChild('ToolInterfaces'))

local LocalPlayerComponent = require(Components:WaitForChild('LocalPlayerComponent'))

local BindsComponent = require(script.BindsComponent)

local ToolComponent = {}

function ToolComponent.new(self: Tool, _Player)
	local self:ToolInterfaces.IToolComponents , isRegistered = BindsComponent.new(self)
	if (isRegistered) then return self end
	
	local Player: LocalPlayerInterfaces.IClientPlayerComponent = LocalPlayerComponent:GetPlayer()
	
	local Character: Model = Player.ClientData.CharacterData.Character
	local Humanoid: Humanoid = Player.ClientData.CharacterData.Humanoid

	if self.Instance:FindFirstChild('Config') then
		self['Config'] = require(self.Instance:FindFirstChild('Config'))
	end
	
	self:BindToEquip(function()
		Player = LocalPlayerComponent:GetPlayer()
		if not self.Equipped then
			self.Equipped = true
			self.Config.LastUsed = os.clock()
			if self.Config.Type == 'Ability' then
				local Ability = Player.ClientData[self.Config.Storage][self.Config.Scope][self.Config.Name]
				
				if (Ability.LastUsed - os.clock()) >= Ability.Cooldown then print(Ability.LastUsed - os.clock()) return end
				
				self.Activated = true
				Ability.LastUsed = os.clock()
				
				self.Threads['Duration'] = RunService.Heartbeat:Connect(function()
					if (os.clock() - Ability.LastUsed) >= Ability.Duration then 
						self.Activated = false
						if self.Threads['Duration'] then
							self.Threads['Duration']:Disconnect()
						end
					end
				end)
				
			end
		end
	end)
	
	self:BindToUnequip(function()
		Player = LocalPlayerComponent:GetPlayer()
		if self.Equipped then
			self.Equipped = false
			if self.Config.Type == 'Ability' then
				local Ability = Player.ClientData[self.Config.Storage][self.Config.Scope][self.Config.Name]
				if os.clock() - Ability.LastUsed < Ability.MinDuration then
					task.delay(Ability.LastUsed + Ability.MinDuration - os.clock(), function()
						self.Activated = false
					end)
				end
			end
		end
	end)
	
	return self
	
end

return ToolComponent
