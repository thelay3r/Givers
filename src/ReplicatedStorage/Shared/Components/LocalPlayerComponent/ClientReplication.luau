local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ContentProvider = game:GetService('ContentProvider')
local Players = game:GetService('Players')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local VFXs = Shared:WaitForChild('VFXs')
local Assets: Folder = VFXs:FindFirstChild('Assets')

local Utilities = Shared:WaitForChild('Utilities')
local NetWork = Utilities:WaitForChild('NetWork')

local Replicator = require(NetWork:WaitForChild('Replicator'))


local ClientReplication = {}
local CachedModules = {}

local VfxRemote = Replicator:GetRemote('VFX')
local BindableGlobal = Replicator:GetRemote('BindableGlobal')

local MAX_PACKET_SIZE = 50

local function PreLoadAssets()
	
	local Packet = {}	
	local counter = 0

	for _, v in pairs(Assets:GetDescendants()) do
		local shouldAdd = false
		local assetToAdd = v

		if v:IsA('Animation') or v:IsA('Decal') or v:IsA('Texture') then
			shouldAdd = true
		elseif v:IsA('ParticleEmitter') then
			shouldAdd = true
			assetToAdd = v.Texture
		end

		if (not shouldAdd) then continue end

		if counter >= MAX_PACKET_SIZE then
			ContentProvider:PreloadAsync(Packet)
			table.clear(Packet)
			counter = 0
			task.wait(1/10)
		end

		table.insert(Packet, assetToAdd)
		counter += 1
	end

	if #Packet > 0 then
		ContentProvider:PreloadAsync(Packet)
	end

end

local function FireVFX(args,...)
	local splitted = string.split(args.VFXType :: string, '.')
	if (#splitted < 2) then return end

	local scope = splitted[1]
	local name = splitted[2]

	local state = args.VfxCFG['State'] or 'Start'
	args.VfxCFG['Player'] = (args.Player) or (Players.LocalPlayer)
	
	local module = CachedModules[type] and CachedModules[type][name][state]
	if not module then return end
	module(args.VfxCFG,...)
end

function ClientReplication:InitClientVFX()
	PreLoadAssets()
	for _,folder in pairs(VFXs.Replica:GetChildren()) do
		if not folder:IsA('Folder') then continue end
		for _,module in pairs(folder:GetChildren()) do
			if not module:IsA('ModuleScript') then continue end
			CachedModules[module.Name] = require(module)
		end
	end
	
	VfxRemote:Connect('PlayVFX',function(arg,...)
		FireVFX(arg)
	end)
	
	BindableGlobal:Connect('PlayVFX',function(arg,...)
		FireVFX(arg)
	end)
end


return ClientReplication
