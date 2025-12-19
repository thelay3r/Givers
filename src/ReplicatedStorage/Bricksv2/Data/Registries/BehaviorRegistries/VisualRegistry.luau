
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local AnimationsInterfaces = require(ReplicatedStorage.Shared.Interfaces.AnimationsInterfaces)
local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local AnimationsComponent = require(ReplicatedStorage.Shared.Utilities.Modules.AnimationsComponent)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local AbilityFolder = Data:WaitForChild('Abilities')
local BlackList = require(AbilityFolder:WaitForChild('BlackList'))

local Assets = ReplicatedStorage:WaitForChild('Shared'):WaitForChild('VFXs'):WaitForChild('Assets')


local VisualRegistry = Registry.new()

VisualRegistry:Register('Root', function(self, node)  
    print('New Root Behavior')
end)


VisualRegistry:Register('IdleAnimation', function(self,node)
    local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
    local Character = Entity.Instance.Character
    local Animator = AnimationsComponent.new(Character) :: AnimationsInterfaces.IAnimationsComponent
    local cfg = node.Config
    print(cfg)
    local NeededPack = Assets:FindFirstChild(cfg.PackName):FindFirstChild('Animations')
    local NeededAnimation = NeededPack:FindFirstChild(cfg.Animation)

    local _animation _,data = Animator:Load(NeededAnimation, cfg.Data)

    Animator:Play(data)

    node.Config['Animator'] = Animator
end)


return VisualRegistry
