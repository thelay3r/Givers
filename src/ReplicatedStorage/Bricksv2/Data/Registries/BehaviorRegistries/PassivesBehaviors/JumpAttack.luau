local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')


local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local Enums = require(ReplicatedStorage.Shared.Utilities.Modules.Enums)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))

local PassiveRegistry = Registry.new()

PassiveRegistry:Register('ValideJumpAttack', function(self,node): any
	local EventData = self.Tags['OnM1Start']['EventData']
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	local Character: Model = Owner.Instance.Character
	local Humanoid: Humanoid = Character:FindFirstChildOfClass('Humanoid')

	return Humanoid:GetState() == Enum.HumanoidStateType.Freefall
end)

PassiveRegistry:Register('JumpAttack', function(self,node)
    local EventData = self.Tags['OnM1Start']['EventData']
	local Owner = EventData['Owner'] :: EntityInterfaces.IEntityComponent
	if EventData.Blocked then return end
	EventData.Blocked = true

	TaskManager:CancelTask(Owner, 'ResetCombo')
	Owner:SetStatusEffect('CurrentCombo',0)
	

	local injectWeapon = 'M1'..EventData.Weapon
	local JumpAction = 'Action.'..EventData.Weapon..'Jump'
    self:Execute({
		Name = 'Action.Extend';
		Config = {
			Inject = {
				injectWeapon
			}
		}
	})
	
	self:Execute({
        Name = JumpAction --'Action.FistJump'--..EventData.Weapon..'Jump';
    })

end)


return PassiveRegistry
