local RunService = game:GetService("RunService")
if RunService:IsClient() then return {} end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')


local Components = Bricks:WaitForChild('Components')
local _Data = Bricks:WaitForChild('Data')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local Enums = require(ReplicatedStorage.Shared.Utilities.Modules.Enums)
local Ragdoll = require(ReplicatedStorage.Shared.Utilities.Modules.Ragdoll)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))



local KnockDownRegistry = Registry.new()

local ApplyForm = {
	[true] = 'Enabled';
	[false] = 'Disabled';
}

KnockDownRegistry:Register('KnockDown', function(self,node)
    local EventData = self.Tags['OnKnockDown']['EventData']
	local Entity = EventData['Entity'] :: EntityInterfaces.IEntityComponent
	local SessionData = Entity.SessionData
	local Apply = ApplyForm[EventData['Apply']]
	local Bool = EventData['Apply'] :: boolean

	local Character = Entity.Instance.Character :: Model
	Ragdoll[Apply](Ragdoll,Character)
	
	Entity:SetStatusEffect('KnockDown',Bool)
	Entity:SetStatusEffect('CanBodySimulation',not Bool)
	Entity:SetStatusEffect('CanAutoRotate',not Bool)
    
end)


return KnockDownRegistry
