local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService('Players')
local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local PassiveHandler = require(ReplicatedStorage.Shared.Utilities.Modules.PassiveHandler)

local PassivesFolder = ReplicatedStorage.Shared:WaitForChild('Passives')

type IEntity = EntityInterfaces.IEntityComponent & PlayerInterfaces.IServerPlayerComponent

local Component = {}

local Passives = {}

function Component.GetPassive(self: any & IEntity,name: string)
   -- return PassiveHandler.Getpassive(name,self.SessionData.UserId)
    return Passives[self.SessionData.UserId][name]
end

function Component.GetAllPassives(self: any & IEntity)
	return Passives[self.SessionData.UserId] or {}
end

function Component.TriggerPassives(self: any & IEntity, trigger: string, args: {})
    local sessionData = self.SessionData
    local userId = sessionData.UserId

    if not Passives[userId] then return end
    
    if not self._PassivesSorted or self._PassivesSortedDirty then
        local sorted = {}
        for _, passive in pairs(Passives[userId]) do
            table.insert(sorted, passive)
        end
        
        table.sort(sorted, function(a, b)
            local priorityA = (a.Instance.Tree.Config.Priority or 0)
            local priorityB = (b.Instance.Tree.Config.Priority or 0)
            return priorityA > priorityB
        end)
        
        self._PassivesSorted = sorted
        self._PassivesSortedDirty = false
    end
    
    for _, passive in pairs(self._PassivesSorted) do
        passive:Trigger(trigger, args)
    end
end

function Component.InvalidatePassiveCache(self: any & IEntity)
    self._PassivesSortedDirty = true
end


function Component.AppendPassive(self: IEntity,pack: string,name: string)
    local sessionData = self.SessionData

    -- require passive module from Shared/Abilities and create passive instance via PassiveHandler
    assert(PassivesFolder:FindFirstChild(pack), (`%s pack doesn't exist`):format(pack))
    assert(PassivesFolder[pack]:FindFirstChild(name), (`%s passive doesn't exist in %s pack`):format(name, pack))


    local module = PassivesFolder[pack][name]:Clone()
    local passiveModule = require(module :: any) :: {}
    module:Destroy()
    local passive = PassiveHandler.new(passiveModule) :: any

    passive:BindToEntity(name,sessionData.UserId)
    
	
    passive.Instance.Tags['Owner'] = self
	self.SessionData.Passives[name] = passive    


    if (not Passives[sessionData.UserId]) then Passives[sessionData.UserId] = {} end
    Passives[sessionData.UserId][name] = passive

    self:InvalidatePassiveCache()
    return passive
end

function Component.RemovedPassive(self: IEntity,name: string)

    local sessionData = self.SessionData

    local passive = PassiveHandler.GetPassive(name,sessionData.UserId)
    passive:UnBindToEntity(name,sessionData.UserId)

    self.SessionData.Passives[name] = nil
    Passives[sessionData.UserId][name] = nil

    self:InvalidatePassiveCache()
    return
end

return Component