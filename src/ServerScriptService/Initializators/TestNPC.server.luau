local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')
local Components = ServerScriptService:WaitForChild('Components')

local Replicator = require(NetWork:WaitForChild('Replicator'))
local NPCComponents = require(Components:WaitForChild('NPCComponent'))
local EntitiesComponent = require(Components:WaitForChild('EntitiesStorage'))

local NPcHandler = require(Components.NPcHandler)

local Map = workspace.Map
local Spawners = Map.Spawner
local Spawner = Spawners.Spawner

local test = NPcHandler.new(Spawner)

--local NPCComponent = NPCComponents.New(NPCs.TestModel)
--EntitiesComponent:Add(NPCComponent)
--Replicator:GetRemote('BindableGlobal'):BindableFire('SetUp', NPCComponent.SessionData.UserId)
