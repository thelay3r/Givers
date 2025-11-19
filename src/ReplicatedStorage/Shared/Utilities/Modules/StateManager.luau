local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Interfaces = Shared:WaitForChild("Interfaces")
local Utilities = Shared:WaitForChild("Utilities")
local UtilModules = Utilities:WaitForChild("Modules")

local TaskManager = require(UtilModules:WaitForChild("TaskManager"))
local StatesInterfaces = require(Interfaces:WaitForChild("StatesInterfaces"))

type IStatesComponent = StatesInterfaces.IStatesComponent
type Iargs = StatesInterfaces.Iargs
type IBehavior = StatesInterfaces.IBehavior

local StateManager = {}
local Managers: { [any]: IStatesComponent } = {}

function StateManager.CheckBehavior(self: IStatesComponent)
	
	if self.BehaviorName ~= "Default" then
		return StateManager.CheckSpecificBehavior(self)
	end
	if self.LockMode then
		return StateManager.CheckLockedBehavior(self)
	else
		return StateManager.CheckCycleBehavior(self)
	end
end

function StateManager.CheckSpecificBehavior(self: IStatesComponent)
	local behaviors = self:SortedBehaivors()
	local behavior = behaviors[self.BehaviorName]

	if not behavior then return end

	local passed = behavior.check(self)
	if passed then
		if self.Behaivor ~= behavior then
			if self.Behaivor and self.Behaivor.falseaction then
				self.Behaivor.falseaction(self)
			end
			self.Behaivor = behavior
			if behavior.trueaction then
				behavior.trueaction(self)
			end
		end
	else
		if behavior.falseaction then
			behavior.falseaction(self)
		end
		self.Behaivor = nil
	end
end

function StateManager.CheckCycleBehavior(self: IStatesComponent)
	local behaviors = self:SortedBehaivors()
	
	for _, behavior: IBehavior in pairs(behaviors) do
		local passed = behavior.check(self)
		if passed then
			if behavior.trueaction then
				behavior.trueaction(self)
			end
		else
			if behavior.falseaction then
				behavior.falseaction(self)
			end
		end
		
	end
end

function StateManager.CheckLockedBehavior(self: IStatesComponent)
	local behaviors = self:SortedBehaivors()
	local current = self.Behaivor
	local highest: IBehavior? = nil
	
	
	
	for _, behavior: IBehavior in pairs(behaviors) do
		if behavior.check(self) then
			if not highest or behavior.priority > highest.priority then
				highest = behavior
			end
		end
	end
	
	
	if highest then
		if not current or highest.priority > current.priority then
			if current and current.falseaction then
				current.falseaction(self)
			end
			self.Behaivor = highest
			if highest.trueaction then
				highest.trueaction(self)
			end
		end
	else
		if current and current.falseaction then
			current.falseaction(self)
		end
		self.Behaivor = nil
	end
end

function StateManager:SetLockMode(state: boolean)
	self.LockMode = state
end

function StateManager.SortedBehaivors(self: IStatesComponent): { IBehavior }
	local Behaviors = require(self.Folder:WaitForChild("Behaviors"))
	local section = Behaviors[self.SectionName]

	if not section then
		return {}
	end

	table.sort(section, function(a, b)
		return a.priority > b.priority
	end)

	return section
end

function StateManager.ChangeState(self: IStatesComponent)
	local States = require(self.Folder:WaitForChild("States"))
	local State = States[self.SectionName]
	if not State then
		return
	end

	if self.State then
		task.cancel(self.State)
	end

	self.State = task.spawn(function()
		State.action(self)
	end)
end

function StateManager:Destroy()
	local self = self :: IStatesComponent

	TaskManager:CancelAllTasks(self)
	TaskManager:CancelAllThreads(self)

	if self.Threads then table.clear(self.Threads) end
	if self.args then table.clear(self.args) end
	if self.Tasks then table.clear(self.Tasks) end

	self.Threads = nil
	self.args = nil
	self.Tasks = nil
	self.Behaivor = nil
	self.State = nil
	self.Ignore = nil
	self.BehaviorName = nil
	self.Update = nil
	self.SectionName = nil
	self.LockMode = nil

	table.clear(self)
	setmetatable(self, nil)
end

function StateManager:New(args: Iargs): IStatesComponent?
	if not args then
		return
	end
	if not args.FOLDER then
		return
	end
	
	local self = setmetatable({
		Folder = args.FOLDER,
		SectionName = args.SECTION_NAME or "Default",
		BehaviorName = args.BEHAVIOR_NAME or "Default",
		StateName = args.STATE_NAME or 'Default',
		Ignore = args.IGNORE or false,
		State = false,
		Behaivor = false,
		Update = args.UPDATE or false,
		LockMode = args.LOCK_MODE or false,
		Parent = args.PARENT or nil;
		Launch = args.LAUNCH or false;
		args = args,
		Tasks = {},
		Threads = {},
	}, {
		__index = StateManager,
	}) :: IStatesComponent

	if self.Launch then StateManager.Launch(self, args) end

	if self.Parent then
		Managers[self.Parent] = Managers[self.Parent] or {}
		Managers[self.Parent][self.StateName] = self
	end

	return self
end

function StateManager.Launch(self: IStatesComponent, args: Iargs)
	if not self.Update then
		self:CheckBehavior()
		return
	end
	
	if args.UPDATE_TIME and args.UPDATE_TIME ~= 1 / 60 then
		TaskManager:CreateTask(self, "Behaviors", 0, function()
			while self.Update do
				self:CheckBehavior()
				task.wait(args.UPDATE_TIME or 1)
			end
		end)
	else
		TaskManager:CreateThread(
			self,
			"Behaviors",
			RunService.RenderStepped:Connect(function()
				if not self.Update then
					TaskManager:CancelThread(self, "Behaviors")
					return
				end
				self:CheckBehavior()
			end)
		)
	end
end



function StateManager:Get(Parent: any, StateName: string): IStatesComponent?
	return Managers[Parent][StateName]
end

function StateManager.ChangeUpdate(self: IStatesComponent, Update: boolean)
	self.Update = Update
	StateManager.Launch(self, self.args)
end

function StateManager.ChangeType(self: IStatesComponent, Type: string)
	local Manager = StateManager.Get(self)
	if Manager then
		Manager.Type = Type
	end
end

return StateManager
