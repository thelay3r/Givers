local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Modules = ReplicatedStorage:WaitForChild('Modules')
local Interfaces = Shared:WaitForChild("Interfaces")
local Utilities = Modules:WaitForChild('Utilities')

local TaskManager = require(Utilities:WaitForChild("TaskManager"))
local StatesInterfaces = require(Interfaces:WaitForChild("StatesInterfaces"))

type IStatesComponent = StatesInterfaces.IStatesComponent
type Iargs = StatesInterfaces.Iargs
type IBehavior = StatesInterfaces.IBehavior

local StateManager = {}
local Managers: { [any]: { [string]: IStatesComponent } } = {}

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
	local behaviors = StateManager.SortedBehaviors(self)
	local behavior = behaviors[self.BehaviorName]

	if not behavior then
		return
	end

	local passed = behavior.check(self)
	if passed then
		if self.Behavior ~= behavior then
			if self.Behavior and self.Behavior.falseaction then
				self.Behavior.falseaction(self)
			end
			self.Behavior = behavior
			if behavior.trueaction then
				behavior.trueaction(self)
			end
		end
	else
		if behavior.falseaction then
			behavior.falseaction(self)
		end
		self.Behavior = nil
	end
end

function StateManager.CheckCycleBehavior(self: IStatesComponent)
	local behaviors = StateManager.SortedBehaviors(self)

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
	local behaviors = StateManager.SortedBehaviors(self)
	local current = self.Behavior
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
			self.Behavior = highest
			if highest.trueaction then
				highest.trueaction(self)
			end
		end
	else
		if current and current.falseaction then
			current.falseaction(self)
		end
		self.Behavior = nil
	end
end

function StateManager:SetLockMode(state: boolean)
	self.LockMode = state
end

function StateManager.SortedBehaviors(self: IStatesComponent): { [string]: IBehavior }
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
	TaskManager:CancelAllTasks(self)
	TaskManager:CancelAllThreads(self)

	if self.Threads then
		table.clear(self.Threads)
	end
	if self.args then
		table.clear(self.args)
	end
	if self.Tasks then
		table.clear(self.Tasks)
	end

	self.Threads = nil
	self.args = nil
	self.Tasks = nil
	self.Behavior = nil
	self.State = nil
	self.Ignore = nil
	self.BehaviorName = nil
	self.Update = nil
	self.SectionName = nil
	self.LockMode = nil

	if self.Parent and Managers[self.Parent] then
		Managers[self.Parent][self.StateName] = nil
	end

	table.clear(self)
	setmetatable(self, nil)
end

function StateManager:New(args: Iargs): IStatesComponent?
	if not args or not args.FOLDER then
		return
	end

	local newComponent = setmetatable({
		Folder = args.FOLDER,
		SectionName = args.SECTION_NAME or "Default",
		BehaviorName = args.BEHAVIOR_NAME or "Default",
		StateName = args.STATE_NAME or "Default",
		Ignore = args.IGNORE or false,
		State = false,
		Behavior = false,
		Update = args.UPDATE or false,
		LockMode = args.LOCK_MODE or false,
		Parent = args.PARENT or nil,
		Launch = args.LAUNCH or false,
		args = args,
		Tasks = {},
		Threads = {},
	}, {
		__index = StateManager,
	}) :: IStatesComponent

	if newComponent.Parent then
		if not Managers[newComponent.Parent] then
			Managers[newComponent.Parent] = {}
		end
		Managers[newComponent.Parent][newComponent.StateName] = newComponent
	end

	if newComponent.Launch then
		StateManager.Launch(newComponent, args)
	end

	return newComponent
end

function StateManager.Launch(self: IStatesComponent, args: Iargs)
	if not self.Update then
		self:CheckBehavior()
		return
	end

	TaskManager:CancelThread(self, "Behaviors")
	TaskManager:CancelTask(self, "Behaviors")

	local updateTime = args.UPDATE_TIME or 1 / 60

	if updateTime ~= 1 / 60 then
		TaskManager:CreateTask(self, "Behaviors", 0, function()
			while self.Update do
				self:CheckBehavior()
				task.wait(updateTime)
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

function StateManager:Get(parent: any, stateName: string): IStatesComponent?
	if not Managers[parent] then
		return nil
	end
	return Managers[parent][stateName]
end

function StateManager.ChangeUpdate(self: IStatesComponent, update: boolean)
	self.Update = update
	StateManager.Launch(self, self.args)
end

function StateManager.ChangeType(self: IStatesComponent, typeValue: string)
	local Manager = StateManager:Get(self.Parent, self.StateName)
	if Manager then
		Manager.Type = typeValue
	end
end

return StateManager