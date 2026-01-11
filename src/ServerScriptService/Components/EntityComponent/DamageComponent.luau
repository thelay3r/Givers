local ReplicatedStorage = game:GetService('ReplicatedStorage')

local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)

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

function DamageComponent.TakeDamage(self: any & IEntityComponent,Damage: number,lethal: boolean)
    local _Instance = self.Instance
    local Character = _Instance.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end
    local sessionData = self.SessionData
    local Attributes = sessionData.Attributes
    if (Damage <= 0) or sessionData.StatusEffects.IFRAME then return end
    
    local DamageToApply = math.clamp(Attributes.Health - Damage, 1, self.SessionData.Attributes.MaxHealth)
    
    if lethal and Damage >= Attributes.Health then
        DamageToApply = -1
    end

    self:SetAttribute('Health', DamageToApply )
    Humanoid.Health = Attributes.Health
    warn(DamageToApply)
    if DamageToApply ~= 1 then return end
    self:TriggerPassives('OnKnockDown',
    {
        Entity = self;
        Apply = true;
    })
end

local PostureTickRate = 3
local PosturePercent = 15

function DamageComponent.TakePosture(self: any & IEntityComponent,Damage: number)
    local _Instance = self.Instance
    local sessionData = self.SessionData
    local Attributes = sessionData.Attributes
    local newPostureValue = math.clamp(Attributes.Posture + Damage, 1, self.SessionData.Attributes.MaxPosture) + 15
    self:SetAttribute('Posture', newPostureValue)
    
    TaskManager:CreateTask(_Instance, 'PostureDelay', 4, function(a0)  
        while Attributes.Posture ~= 0 do
            local Posture = Attributes.Posture
            local _newPostureValue = Posture * PosturePercent / 100
            self:SetAttribute('Posture', Posture - _newPostureValue)
            task.wait(PostureTickRate)
        end
    end)

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
