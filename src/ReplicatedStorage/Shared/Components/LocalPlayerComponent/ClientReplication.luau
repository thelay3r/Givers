local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ContentProvider = game:GetService('ContentProvider')

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

local function PreLoadAssets()
	
	local Packet = {}
	local MaxSize = 50
	
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

			if shouldAdd then
				if counter >= MaxSize then
					ContentProvider:PreloadAsync(Packet)
					table.clear(Packet)
					counter = 0
					task.wait(1/10)
				end
				table.insert(Packet, assetToAdd)
				counter += 1
			end
		end

		if #Packet > 0 then
			ContentProvider:PreloadAsync(Packet)
		end

	
end

local function fireVfx(args,...)
		local pack = args.Pack
		local name = args.Name
		local scope = args.State
		local side = args.Side
		
		if not CachedModules[pack] or not CachedModules[pack][name] or not CachedModules[pack][name][side][scope] then return end
		return CachedModules[pack][name][side][scope](...)
end

function ClientReplication:InitClientVFX()
	PreLoadAssets()
	for _,folder in pairs(VFXs.Replica:GetChildren()) do
		if not folder:IsA('Folder') then continue end
		CachedModules[folder.Name] = {}
		for _,module in pairs(folder:GetChildren()) do
			if not module:IsA('ModuleScript') then continue end
			CachedModules[folder.Name][module.Name] = require(module)
		end
	end
	
	VfxRemote:Connect('VFX',function(arg,...)
		fireVfx(arg)
	end)
	BindableGlobal:Connect('PlayVFX',function(arg,...)
		fireVfx(arg)
	end)
end


return ClientReplication
