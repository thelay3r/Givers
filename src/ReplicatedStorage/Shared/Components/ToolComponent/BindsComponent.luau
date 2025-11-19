local UserInputService = game:GetService('UserInputService')

local BindsComponent = {}

BindsComponent.__index = BindsComponent

local Components: {typeof(BindsComponent)} = {}

function BindsComponent:BindToEquip(callback: () -> {})
	table.insert(self.OnEquip, callback)
end

function BindsComponent:BindToUnequip(callback: () -> {})
	table.insert(self.OnUnequip, callback)
end

function BindsComponent:BindToClick(callback: () -> {})
	table.insert(self.OnClick, callback)
end

function BindsComponent:BindToDown(callback: () -> {})
	table.insert(self.OnDown, callback)
end

function BindsComponent:BindToUp(callback: () -> {})
	table.insert(self.OnUp, callback)
end

function BindsComponent:BindToCallback(name: string, callback: (...any) -> {})
	self.Callbacks[name] = callback
end

function BindsComponent:OnCallback(name: string, ...: any)
	if (not self.Callbacks[name]) then warn(name..' callback doesnt exist'); return end
	self.Callbacks[name](...)
end

function BindsComponent:BindToDestoy(callback: () -> {})
	table.insert(self.OnDestroy, callback)
end

function BindsComponent.new(Tool: Tool): typeof(BindsComponent) & {['Instance']: Tool}
	if (Components[Tool]) then return Components[Tool], true end
	
	if (not Tool:IsA('Tool')) then return end
	
	local self = setmetatable({
		
		Instance = Tool;
		Equipped = false;
		Activated = false;
		
		OnEquip = {};
		OnUnequip = {};
		OnClick = {};
		OnDown = {};
		OnUp = {};
		OnDestroy = {};
		
		CallBacks = {};
		
		Config = 
			{
				Type = 'Basic';
				LastUsed = os.clock();
			};
		
		Tasks = {};
		Threads = {};
		
	}, BindsComponent)
	
	local clickConnection;
	clickConnection = Tool.Activated:Connect(function()
		for _, callback in pairs(self.OnClick) do callback() end
	end)
	
	local onDownConnection;
	onDownConnection = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			for _, callback in pairs(self.OnDown) do callback() end
		end
	end)
	
	local onUpConnection;
	onUpConnection = UserInputService.InputEnded:Connect(function(input, gpe)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			for _, callback in pairs(self.OnUp) do callback() end
		end
	end)
	
	local equipConnection;
	equipConnection = Tool.Equipped:Connect(function()
		for _, callback in pairs(self.OnEquip) do callback() end
	end)
	
	local unequipConnection;
	unequipConnection = Tool.Unequipped:Connect(function()
		for _, callback in pairs(self.OnUnequip) do callback() end
	end)
	
	local destsoyConnection;
	destsoyConnection = Tool.Destroying:Connect(function()
		clickConnection:Disconnect()
		equipConnection:Disconnect()
		unequipConnection:Disconnect()

		-- !! rewrite into table.clear to avoid leaks

		for _, callback in pairs(self.OnDestroy) do callback() end

		for _,v in pairs(self) do
			if typeof(v) == 'table' then
				table.clear(v)
			end
		end

		for i, v in pairs(self.Tasks) do
			if self.Tasks[v] then
				task.cancel(v)
				self.Tasks[v] = nil
			end
		end

		for i, v in pairs(self.Threads) do
			if self.Threads[v] then
				v:Disconnect()
				self.Threads[v] = nil
			end
		end

		self.OnClick = nil
		self.OnDown = nil
		self.OnUp = nil
		self.OnEquip = nil
		self.OnUnequip = nil
		self.OnDestroy = nil
		self.Callbacks = nil
		self.Tasks = nil
		self.Threads = nil

		setmetatable(self, nil)
		table.clear(self)
		Components[Tool] = nil

		clickConnection = nil
		equipConnection = nil
		unequipConnection = nil       

		destsoyConnection:Disconnect()
		self = nil
	end)
	
	Components[Tool] = self

	return self
	
end

return BindsComponent
