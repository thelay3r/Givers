local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local LocalPlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.LocalPlayerInterfaces)
local PassiveHandler = require(Modules:WaitForChild('PassiveHandler'))



type IEntity = LocalPlayerInterfaces.IClientPlayerComponent

local Component = {}

local Abilities = {}


function Component.GetAbility(self: IEntity,name: string)
    local UserId = self.Instance.UserId
    return Abilities[UserId][name]
end

function Component.AppendAbility(self: IEntity,pack: string,name: string)
    local UserId = self.Instance.UserId

    local ability = PassiveHandler.createByName(pack, name)
    ability:BindToEntity(name,UserId)
    local Tree = ability.Instance.Tree
    local Config = Tree.Config
    
    ability.Instance.Tags['Owner'] = self

    self.ClientData.Abilities[Config.KeyCode.Name] =
    {
        Name = name;
    }

    if (not Abilities[UserId]) then Abilities[UserId] = {} end
    Abilities[UserId][name] = ability
    return 
end

function Component.RemovedAbility(self: IEntity,name: string)
    local UserId = self.Instance.UserId

    local ability = PassiveHandler.GetPassive(name,UserId)
    ability:UnBindToEntity(name,UserId)

    return
end

return Component