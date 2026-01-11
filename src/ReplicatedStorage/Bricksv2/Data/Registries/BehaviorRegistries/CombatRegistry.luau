
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Bricks = ReplicatedStorage:WaitForChild('Bricksv2')

local Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local Registries = Data:WaitForChild('Registries')

local PlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.PlayerInterfaces)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(Components:WaitForChild('Registry'))
local AbilityParser = require(Components:WaitForChild('AbilityParser'))

local AbilityFolder = Data:WaitForChild('Abilities')
local BlackList = require(AbilityFolder:WaitForChild('BlackList'))


local EntityRegistry = Registry.new()

EntityRegistry:Register('Root', function(self, node)  
end)

EntityRegistry:Register('AutoCombo', function(self,node)  
    local Main = self.Tags['Main']
    local Owner = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent

    if TaskManager.GetTask(Owner, 'AutoCombo') then
        return
    end
     
    TaskManager:CreateTask(Owner, 'AutoCombo', 0, function(a0)
        while Main.PlayerPressed do
            task.wait(Main.CoolDown - .1)
            if not Main.PlayerPressed then
                TaskManager:CancelTask(Owner, 'AutoCombo')
                break
            end

            self:Execute({
            Name = 'Action.TriggerEvent',
            Config = {
                TagName = 'OnStart',
            }})
        end
    end)

end)

EntityRegistry:Register('Combo', function(self, node)
	local Entity = self.Tags['Owner'] :: PlayerInterfaces.IServerPlayerComponent
	local Session = Entity.SessionData
    local config = node.Config
    local combo = config.Combo
    local timings = config.Timings
    if not combo then return end

    Session.StatusEffects.CurrentCombo += 1

    local split

    local newCombo = {}
    
    for i,v in pairs(combo) do 
        split = string.split(v,'.')
        if #split < 2 then newCombo[i] = v 
            continue 
        end
        for _i=1,split[2] do
            table.insert(newCombo,split[1])
        end
    end


    local TargetAction = newCombo[Session.StatusEffects.CurrentCombo]
    if not TargetAction then
        local try = 1
        while not TargetAction do
            if try >= 4 then return end
            TargetAction = newCombo[Session.StatusEffects.CurrentCombo - try]
            try+=1
        end
    end

    local PassiveTable = {
        Weapon = TargetAction;
        Owner = Entity;
        Blocked = false;
    }
    Entity:TriggerPassives('OnM1Start',PassiveTable)
    if PassiveTable.Blocked then return end
    
    
    self:Execute({
        Name = 'Action.'..TargetAction;
    })

    if Session.StatusEffects.CurrentCombo >= 4 then 
        Session.StatusEffects.CurrentCombo = 0 
        self:Execute({
            Name = 'Action.SetRootCoolDown';
            Config = {
                CoolDown = (timings[TargetAction].Combo) or 2;
            }
        })

        TaskManager:CreateTask(Entity, 'ClickCoolDown', 2, function()  
            self:Execute({
                Name = 'Action.SetRootCoolDown';
                Config = {
                    CoolDown = (timings[TargetAction].Main) or .35; 
                }
            })
        end)
    end

    TaskManager:CreateTask(Entity, 'ResetCombo', 1.5, function()  
        Session.StatusEffects.CurrentCombo = 0
    end)

end)

return EntityRegistry
