local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')
local RunService = game:GetService('RunService')

local Services = ServerScriptService:WaitForChild('Services')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Templates = Shared:WaitForChild('Templates')
local Interfaces = Shared:WaitForChild('Interfaces')

local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

--local profilestore = require(ServerScriptService.ServerPackages.profilestore)
local EntityInterfaces = require(ReplicatedStorage.Shared.Interfaces.EntityInterfaces)
local ProfileStore = require(Services:WaitForChild('ProfileStore'))
local ReplicaService = require(Services:WaitForChild('ReplicaService'))

local PlayerInterfaces = require(Interfaces:WaitForChild('PlayerInterfaces'))
local ProfileTemplate = require(Templates:WaitForChild('ProfileStoreTemplate'))
local SessionTemplate = require(Templates:WaitForChild('SessionData')) 



type IProfile = typeof(ProfileTemplate)
type iSession = typeof(SessionTemplate())

local LiveIndex = require(script.LiveIndex)
local StudioIndex = require(script.StudioIndex)

local TOKEN = ReplicaService.Token('PlayerData')

local DataProfile = {}

local Index

if RunService:IsStudio() then
	Index = StudioIndex
else
	Index = LiveIndex
end

local ScopedProfile = ProfileStore.New(Index, ProfileTemplate)

--local Profile = ProfileStore.GetProfileStore(Index, ProfileTemplate)

function DataProfile.LoadProfile(self: PlayerInterfaces.IServerPlayerComponent)
	local player = self.Instance
	
	local profile = ScopedProfile:StartSessionAsync(tostring(player.UserId))
	
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
	end


	return profile
	
end

function DataProfile.LoadReplica(self: PlayerInterfaces.IServerPlayerComponent & EntityInterfaces.IEntityComponent & {LoadProfile: (PlayerInterfaces.IServerPlayerComponent) -> any})
	
	local replica = ReplicaService.New({
		Token = TOKEN;
		Data = {Profile = self:LoadProfile(), Session = SessionTemplate()} :: {Profile: IProfile, Session: iSession};
		Tags = 
			{
				UserId = self.Instance.UserId;
			};
	})
	
	self.Replica = replica
	self.SessionData = self.Replica.Data.Session
	self.Replica.Data.Session.UserId = tostring( self.Instance.UserId )

	--if true then return replica end
	task.wait(1)
	replica:Subscribe(self.Instance)
	

	
	return replica
end


return DataProfile
