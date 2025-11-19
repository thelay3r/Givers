--!optimize 2
--!strict

local ServerScriptService = game:GetService('ServerScriptService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')

local Services = ServerScriptService:WaitForChild('Services')

local PlayerService = require(Services:WaitForChild('PlayerComponentService'))

-- // delete after testing

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

local ServerComponents = ServerScriptService:WaitForChild('Components')

local PacketManager = require(NetWork:WaitForChild('Packets'))
local EntitiesStorage = require(ServerComponents:WaitForChild('EntitiesStorage'))

--local AbilityPacket = PacketManager("Ability", PacketManager.Any) 

-- // delete after testing

--[[
	Name: string;
	Key: Enum.KeyCode;
	State: Enum.UserInputState;
]]
--{ { Name = 'teest', Key = Enum.KeyCode.X, State = Enum.UserInputState.Begin } }
Players.PlayerAdded:Connect(function(player: Player)
	task.wait(3)

	local PlayerComponent = PlayerService:CreateComponent(player)
	
	PlayerComponent.SessionData.Equipment = table.clone(PlayerComponent.Profile.Data.Equipment)
	EntitiesStorage:Add(PlayerComponent)
	PlayerComponent.SessionData.Settings.Loaded = true
end)

Players.PlayerRemoving:Connect(function(player: Player)
	PlayerService:RemoveComponent(player)
end)
