local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerScriptService = game:GetService('ServerScriptService')

local Components = ServerScriptService:WaitForChild('Components')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local NPCsFolder = Shared:WaitForChild('NPCsFolder')
local Interfaces = Shared:WaitForChild('Interfaces')
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Utilities = Modules:WaitForChild('Utilities')


local NPcHandlerInterfaces = require(Interfaces:WaitForChild('NPcHandlerInterface'))

local TaskManager = require(Utilities:WaitForChild('TaskManager'))
local TableHelper = require(Utilities:WaitForChild('TableHelper'))
local NPcComponent = require(Components:WaitForChild('NPCComponent'))
local NpcBeahaivor = Components:WaitForChild('NpcBehaivor')

type INPcHandler = NPcHandlerInterfaces.NPcHandlerComponent

local NPcHandler = {}

local Methods: { [string]: (INPcHandler, ...any) -> ...any } = {}

local function RandomVector3(min,max)
	return Vector3.new(math.random(min,max),0,math.random(min,max))
end

function Methods._SpawnBranch(self: INPcHandler)
	if not self.Active then return end
	
	TaskManager:CreateTask(self,'SpawnBranch',0,function()
		while self.Active do
			task.wait(1)
			local AliveIndexsCount = TableHelper:CheckIndexCount(self.AliveNPCs)
			local toSpawn = math.min(self.Count - AliveIndexsCount,self.Count)
			if toSpawn ~= self.Count then continue end
			
			local t= .5
			
			for i=1,toSpawn do
				self:_Create()
				task.wait(t)
			end
			
		end
		
	end)
end

function Methods._CreateModel(self: INPcHandler)
	local Model: Model = NPCsFolder:FindFirstChild(self.Type):FindFirstChild(self.NpcName):Clone()
	if not Model then return end
	Model:PivotTo(self._Instance.CFrame + RandomVector3(-2,2))
	
	
	return Model
end

function Methods._Create(self: INPcHandler)
	local Model = self:_CreateModel()
	local npc = NPcComponent.New(Model)
	self.AliveNPCs[npc.SessionData.UserId] = self
	
	local CharacterData = npc.SessionData.CharacterData
	local Humanoid = CharacterData.Humanoid

	

	Humanoid.Died:Once(function()
		self.AliveNPCs[npc.SessionData.UserId] = nil
	end)
	
	if not NpcBeahaivor:FindFirstChild(self.CFG) then return npc end
	local module = require(NpcBeahaivor:FindFirstChild(self.CFG))
	if not module then return npc end
	module(npc)

	return npc
end

function NPcHandler.new(Part: BasePart)
	
	local CFG = Part:GetAttribute('CFG')
	if not CFG then return end
	local NPC = Part:GetAttribute('NPC')
	if not NPC then return end
	local Type = Part:GetAttribute('Type')
	if not Type then return end
	local Count = (Part:GetAttribute('Count')) or 1
	
	
	local self = setmetatable(
		{
			AliveNPCs = {};
			Active = false;

			Count = Count;
			NpcName = NPC;
			Type = Type;
			CFG = CFG;
			
			_Instance = Part;
		},
	{
		__index = function(t,key)
			return Methods[key] or NPcHandler[key]
		end,
	}) :: any & INPcHandler
	
	self.Active = true
	self:_SpawnBranch()
	
	return self
end


return NPcHandler
