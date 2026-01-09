local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService('RunService')

local CacheContainer = require(ReplicatedStorage.Shared.Utilities.Modules.CacheContainer)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local RockModule = {}

type IConfig = {
    Duration: number;
    TickRate: number;
    Radius: number;
    Character: Model;
}

local RockContainer = CacheContainer.new()

function RockModule.SpawnRocks(config: IConfig)
    
    local RootPart = config.Character:FindFirstChild('HumanoidRootPart') :: BasePart
    if not RootPart then return end

    
    local counter = 0
    TaskManager:CreateThread(config.Character, 'RockSpawner', RunService.Heartbeat:Connect(function(dt)  
        counter += dt
        if counter <= 1/(config.TickRate or 30) then return end 
        counter = 0

        for i=-1,2,2 do
            
            

        end

    end))

end


return RockModule