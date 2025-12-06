
local RunService = game:GetService("RunService")

local Replicator = {}


local RemoteController = {}

local Remotes = {}

function RemoteController:Fire(...)
	if game:GetService("RunService"):IsServer() then
		self.Instance:FireClient(...)
	else
		self.Instance:FireServer(...)
	end
end


function RemoteController:BindableFire(...)
	self.Instance:Fire(...)
end

function RemoteController:FunctionFire(...)
	if RunService:IsServer() then
		return self.Instance:InvokeClient(...)
	else
		return self.Instance:InvokeServer(...)
	end
end



function RemoteController:FireInRadius(FirePosition, radius, ...)
	local playersInRadius = {}
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		local character = player.Character or player.CharacterAdded:Wait()
		if not character or not player then return end
		if (player.Character.PrimaryPart.Position - FirePosition).Magnitude < radius then
			table.insert(playersInRadius, player)
		end
	end
	for _, player in ipairs(playersInRadius) do
		self.Instance:FireClient(player, ...)
	end
end

function RemoteController:Connect(name,callBack): typeof(RemoteController)
	if (not self.CallBacks[name]) then self.CallBacks[name] = {} end
	table.insert(self.CallBacks[name], callBack)
	return callBack
end

function RemoteController:GetConnections(name): typeof(RemoteController)
	return self.CallBacks[name]
end

function RemoteController:Wait(name)
	
end

function RemoteController:Disconnect(name)
	if (not self.CallBacks[name]) then return end
	table.clear(self.CallBacks[name])
	self.CallBacks[name] = nil
end

function Replicator:GetRemote(name): typeof(RemoteController)
	return Remotes[name]
end

local function CreateRemote(object:RemoteEvent) 
	local newRemote = setmetatable({},
	{
		__index  = function(t,i)
			return RemoteController[i] or object[i]
		end;
	})
	
	
	newRemote.Instance = object
	newRemote.CallBacks = {}
	
	
	if RunService:IsServer() then
		object.OnServerEvent:Connect(function(player,name,...)
			if newRemote.CallBacks[name] == nil then
				warn("⛔ Remote",object.Name,"has no callback for",name)
				return
			end
			for _,v in pairs(newRemote.CallBacks[name]) do v(player,...) end
		end)
	else
		object.OnClientEvent:Connect(function(name,...)
			if newRemote.CallBacks[name] == nil then
				warn("⛔ Remote",object.Name,"has no callback for",name)
				return
			end
			for _,v in pairs(newRemote.CallBacks[name]) do v(...) end
		end)
	end
		
	Remotes[object.Name] = newRemote
	
	return newRemote
end


local function CreateBindableRemote(object : BindableEvent) 
	local newRemote = setmetatable({},
	{
		__index  = function(t,i)
			return RemoteController[i] or object[i]
		end;
	})

	newRemote.Instance = object
	newRemote.CallBacks = {}

	object.Event:Connect(function(name,...)
		if not newRemote.CallBacks[name] then return end
		for _,v in pairs(newRemote.CallBacks[name]) do v(...) end
	end)
	
	Remotes[object.Name] = newRemote

	return newRemote
end


local function CreateRemoteFunction(object : RemoteFunction) 
	local newRemote = setmetatable({},
	{
		__index  = function(t,i)
			return RemoteController[i] or object[i]
		end;
	})
	
	newRemote.Instance = object
	newRemote.CallBacks = {}
	
	if RunService:IsServer() then
		object.OnServerInvoke = (function(player,name,...)
				if newRemote.CallBacks[name] == nil then
				warn("⛔ RemoteFunction",object.Name,"has no callback for",name)
					return
				end
			return newRemote.CallBacks[name][1](player,...)
		end)
	else
		object.OnClientInvoke = (function(name,...)
			if newRemote.CallBacks[name] == nil then
				warn("⛔ RemoteFunction",object.Name,"has no callback for",name)
				return
			end
			return newRemote.CallBacks[name][1](...)
		end)
	end

	Remotes[object.Name] = newRemote
	
	return newRemote
end

for _, v in pairs(script:GetChildren()) do
	if v:IsA("RemoteEvent") then CreateRemote(v) 
	continue end
	if v:IsA("BindableEvent") then CreateBindableRemote(v) 
	continue end
	if v:IsA("RemoteFunction") then CreateRemoteFunction(v) 
	continue end
end

return Replicator