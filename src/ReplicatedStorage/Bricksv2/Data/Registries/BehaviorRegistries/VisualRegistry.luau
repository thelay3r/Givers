
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')

local AnimationsInterfaces = require(ReplicatedStorage.Shared.Interfaces.AnimationsInterfaces)
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local AnimationsComponent = require(ReplicatedStorage.Shared.Utilities.Modules.AnimationsComponent)
local _TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))
local _AbilityParser = require(Components:WaitForChild('AbilityParser'))

local AbilityFolder = Data:WaitForChild('Abilities')
local _BlackList = require(AbilityFolder:WaitForChild('BlackList'))

local Assets = ReplicatedStorage:WaitForChild('Shared'):WaitForChild('VFXs'):WaitForChild('Assets')


local VisualRegistry = Registry.new()

VisualRegistry:Register('Root', function(self, node)  
end)


VisualRegistry:Register('IdleAnimation', function(self,node)
    local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
    local Character = Entity.Instance.Character
    local Animator = AnimationsComponent.new(Character) :: AnimationsInterfaces.IAnimationsComponent
    local cfg = node.Config
    local NeededPack = Assets:FindFirstChild(cfg.PackName):FindFirstChild('Animations')
    local NeededAnimation = NeededPack:FindFirstChild(cfg.Animation)

    local _animation,data = Animator:Load(NeededAnimation, cfg.Data)

    Animator:Play(data)

    node.Config['Animator'] = Animator
end)


return VisualRegistry
