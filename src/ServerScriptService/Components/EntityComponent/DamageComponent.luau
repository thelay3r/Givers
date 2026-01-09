local ReplicatedStorage = game:GetService('ReplicatedStorage')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)

local DamageComponent = {}

type IEntityComponent = EntityInterfaces.IEntityComponent

function DamageComponent.TakeHealth(self: any & IEntityComponent,Health: number)
    local _Instance = self.Instance
    local Character = _Instance.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    local sessionData = self.SessionData
    local Attributes = sessionData.Attributes
    if (Health <= 0) or sessionData.StatusEffects.IFRAME then return end
    

    self:SetAttribute('Health',  math.clamp(self.SessionData.Attributes.Health + Health, 1, self.SessionData.Attributes.MaxHealth))
    Humanoid.Health = Attributes.Health
end

function DamageComponent.TakeDamage(self: any & IEntityComponent,Damage: number)
    local _Instance = self.Instance
    local Character = _Instance.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    local sessionData = self.SessionData
    local Attributes = sessionData.Attributes
    if (Damage <= 0) or sessionData.StatusEffects.IFRAME then return end
    
    self:SetAttribute('Health',  math.clamp(self.SessionData.Attributes.Health - Damage, 1, self.SessionData.Attributes.MaxHealth))
    Humanoid.Health = Attributes.Health
end
function DamageComponent.TakePosture(self: any & IEntityComponent,Damage: number)
    local _Instance = self.Instance
    local sessionData = self.SessionData
    local Attributes = sessionData.Attributes
    local newPostureValue = math.clamp(Attributes.Posture + Damage, 1, self.SessionData.Attributes.MaxPosture) + 100
    self:SetAttribute('Posture', newPostureValue)
    
    if newPostureValue < Attributes.MaxPosture then return end
    self:TriggerPassives('OnGreatStun',
    {
        Victim = self;
        HitData = {
            ['StunTime'] = 2
        }
    })
end


return DamageComponent
