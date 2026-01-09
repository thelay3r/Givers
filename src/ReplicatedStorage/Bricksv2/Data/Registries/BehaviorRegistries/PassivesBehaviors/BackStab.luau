local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService("ServerScriptService")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')


local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityComponent = require(ServerScriptService.Components.EntityComponent)
local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local Enums = require(ReplicatedStorage.Shared.Utilities.Modules.Enums)
local HitboxClass = require(ReplicatedStorage.Shared.Utilities.Modules.HitboxClass)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local BackStabRegistry = Registry.new()


BackStabRegistry:Register('CanBackStab?', function(self,node): any
	local EventData = self.Tags['OnM1Start']['EventData']
	local Owner = self.Tags['Owner'] :: EntityInterfaces.IEntityComponent
	local RootPart = Owner.SessionData.CharacterData.HumanoidRootPart
    local status = false

	node.Config.Victim = nil

    local CheckBox = HitboxClass.new('WeldedBox', 
	{
		IgnoreCharacters = {Owner.Instance.Character};
		velocityPrediction = true;
		root = Owner.Instance.Character:FindFirstChild('HumanoidRootPart');
		size = Vector3.new(4,4,4);
		debug = false;
		duration = .3;
		proportional = {
			offsetMultiplier = 1;
			DefaultSize = Vector3.new(4,4,4);
		}
	})
	CheckBox:Start()

    local hitCharacter = CheckBox.OnHit:Wait(1/10)
	if not hitCharacter then return false end
	
	local Victim = EntityComponent.GetEntity(hitCharacter:GetAttribute('Id')) :: EntityInterfaces.IEntityComponent
	if not Victim then 
		return false 
	end
	
	if not Victim.SessionData.StatusEffects.GreatStun then 
		return false 
	end
	
	local VictimCharacter = Victim.Instance.Character :: Model
	local VictimRootPart = VictimCharacter:FindFirstChild('HumanoidRootPart') :: BasePart
	
	local dotResult = RootPart.CFrame.LookVector:Dot(VictimRootPart.CFrame.LookVector)
	if dotResult < .25 then return false end
	

	node.Config.Victim = Victim
	
	return true
end)

BackStabRegistry:Register('BackStab', function(self,node)
	local EventData = self.Tags['OnM1Start']['EventData']	if EventData.Blocked then return end
	if EventData.Blocked then return end
	EventData.Blocked = true

	local Owner = EventData['Owner'] :: EntityInterfaces.IEntityComponent
	local GrabData = self.Tags['BackStabCheck']

	Owner:SetStatusEffect('CurrentCombo',0)

	local injectWeapon = 'M1'..EventData.Weapon
	local RunAction = 'Action.'..EventData.Weapon..'BackStab'
    self:Execute({
		Name = 'Action.Extend';
		Config = {
			Inject = {
				injectWeapon
			}
		}
	})
	
	self:Execute({
        Name = RunAction;
		Config = {
			Victim = GrabData['Victim'];
		}
    })

end)


return BackStabRegistry
