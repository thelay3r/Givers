local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ContentProvider = game:GetService('ContentProvider')
local Players = game:GetService('Players')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local VFXs = Shared:WaitForChild('VFXs')
local Assets: Folder = VFXs:FindFirstChild('Assets')

local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

local Replicator = require(NetWork:WaitForChild('Replicator'))


local ServerVFX = {}
local CachedModules = {}

local BindableGlobal = Replicator:GetRemote('BindableGlobal')



local function fireVfx(args,Entity,...)
	local splitted = string.split(args.VFXType :: string, '.')
	if #splitted < 2 then return end
	print(args)
	local _type = splitted[1]
	local name = splitted[2]
	local state = args.EventData['State'] or 'Start'
	args.EventData['Player'] = (args.Player) or Entity
	local module = CachedModules[_type] and CachedModules[_type][name][state]
	print(module,CachedModules)
	if not module then return end
	module(args.EventData,...)
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
		fireVfx(arg,self.Instance)
	end)
end


return ServerVFX
