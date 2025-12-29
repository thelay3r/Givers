local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local Modules = Utilities:WaitForChild('Modules')
local LocalPlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.LocalPlayerInterfaces)
local AbilityHandler = require(Modules:WaitForChild('AbilityHandler'))

local AbilitesFolder = Shared:WaitForChild('Abilities')

type IEntity = LocalPlayerInterfaces.IClientPlayerComponent

local Component = {}

local Abilities = {}


function Component.GetAbility(self: IEntity,name: string)
    local UserId = self.Instance.UserId
    return Abilities[UserId][name]
end

function Component.AppendAbility(self: IEntity,pack: string,name: string)
    local UserId = self.Instance.UserId

    assert(AbilitesFolder:FindFirstChild(pack), (`%s pack doesn't exist`):format(pack))
    assert(AbilitesFolder[pack]:FindFirstChild(name), (`%s ability doesn't exist in %s pack`):format(name, pack))

    
    local abilityModule = AbilitesFolder[pack][name]:Clone()
    local ability = AbilityHandler.new(require(abilityModule))
    abilityModule:Destroy()
    
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

    local ability = AbilityHandler.GetAbility(name,UserId)
    ability:UnBindToEntity(name,UserId)

    return
end

return Component