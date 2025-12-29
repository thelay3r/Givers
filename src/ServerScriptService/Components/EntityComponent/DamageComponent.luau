local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Templates = Shared:WaitForChild('Templates')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local SessionTemplate = require(Templates.SessionData)

local DamageComponent = {}

type IEntityComponent = EntityInterfaces.IEntityComponent

function DamageComponent.TakeDamage(self: IEntityComponent,Enemy: IEntityComponent,Damage: number)
    local _Instance = self.Instance
    local Character = _Instance.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    local sessionData = self.SessionData
    local Attributes = sessionData.Attributes

    Attributes.Health = math.clamp(self.SessionData.Attributes.Health - Damage, 1, self.SessionData.Attributes.MaxHealth)
    Humanoid.Health = Attributes.Health
    Character.PrimaryPart:ApplyImpulse(Character.PrimaryPart.CFrame.lookVector * -50000555)

end

return DamageComponent
