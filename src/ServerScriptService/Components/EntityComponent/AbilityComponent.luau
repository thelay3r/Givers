local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService('Players')
local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local AbilityHandler = require(ReplicatedStorage.Shared.Utilities.Modules.AbilityHandler)



type IEntity = EntityInterfaces.IEntityComponent & PlayerInterfaces.IServerPlayerComponent

local Component = {}

local Abilities = {}


function Component.GetAbility(self: any & IEntity,name: string)
   -- return AbilityHandler.GetAbility(name,self.SessionData.UserId)
    return Abilities[self.SessionData.UserId][name]
end
function Component.GetAbilityByKeyCode(self: any & IEntity,name: string)
   -- return AbilityHandler.GetAbility(name,self.SessionData.UserId)
    return AbilityHandler.GetByKeyCode(name)
end
function Component.AppendAbility(self: any & IEntity,pack: string,name: string)
    local sessionData = self.SessionData

    local ability = AbilityHandler.createByName(pack, name)
    ability:BindToEntity(name,sessionData.UserId)
    local Tree = ability.Instance.Tree
    local Config = Tree.Config
    
    ability.Instance.Tags['Owner'] = self

    if not PlayersService:GetPlayerByUserId(sessionData.UserId) then return end

    self:SetAbility(Config.KeyCode.Name,
    {
        Name = name;
    })
    
    if (not Abilities[sessionData.UserId]) then Abilities[sessionData.UserId] = {} end
    Abilities[sessionData.UserId][name] = ability
    return 
end

function Component.RemovedAbility(self: IEntity,name: string)

    local sessionData = self.SessionData

    local ability = AbilityHandler.GetAbility(name,sessionData.UserId)
    ability:UnBindToEntity(name,sessionData.UserId)

    return
end

return Component