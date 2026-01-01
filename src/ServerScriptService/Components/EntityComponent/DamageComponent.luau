local ReplicatedStorage = game:GetService('ReplicatedStorage')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)

local DamageComponent = {}

type IEntityComponent = EntityInterfaces.IEntityComponent

function DamageComponent.TakeDamage(self: any & IEntityComponent,Damage: number)
    local _Instance = self.Instance
    local Character = _Instance.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    local sessionData = self.SessionData
    local Attributes = sessionData.Attributes

    self:SetAttribute('Health',  math.clamp(self.SessionData.Attributes.Health - Damage, 1, self.SessionData.Attributes.MaxHealth))
    Humanoid.Health = Attributes.Health
end

return DamageComponent
