local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ContentProvider = game:GetService('ContentProvider')
local Players = game:GetService('Players')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local VFXs = Shared:WaitForChild('VFXs')
local Assets: Folder = VFXs:FindFirstChild('Assets')

local Modules = ReplicatedStorage:WaitForChild('Modules')
local NetWork = Modules:WaitForChild('NetWork')

local Replicator = require(NetWork:WaitForChild('Replicator'))


local ServerVFX = {}
local CachedModules = {}

local BindableGlobal = Replicator:GetRemote('BindableGlobal')



local function FireVFX(EventData,...)
	local splitted = string.split(EventData.VFXType :: string, '.')
	if (#splitted < 2) then return end
	
	local scope = splitted[1]
	local name = splitted[2]
	local state = EventData['State'] or 'Start'

	EventData['Player'] = (EventData.Player) or (Players.LocalPlayer)
	local module = CachedModules[scope] and CachedModules[scope][name][state]
	if not module then return end
	module(EventData,...)
end

function ServerVFX:InitVFX()
	for _,folder in pairs(VFXs.Replica:GetChildren()) do
		if not folder:IsA('Folder') then continue end
		for _,module in pairs(folder:GetChildren()) do
			if not module:IsA('ModuleScript') then continue end
			CachedModules[module.Name] = require(module)
		end
	end
	
	BindableGlobal:Connect('PlayVFX',function(arg,...)
		FireVFX(arg,self.Instance)
	end)
end


return ServerVFX
