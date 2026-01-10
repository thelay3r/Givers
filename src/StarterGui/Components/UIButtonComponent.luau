local ButtonComponent = {}
ButtonComponent.__index = ButtonComponent

local Components: {[GuiButton]: typeof(ButtonComponent) & {Instance: GuiButton}} = {}

function ButtonComponent:BindToClick(callback: () -> {})
	table.insert(self.OnClick, callback)
end

function ButtonComponent:BindToEnter(callback: () -> {})
	table.insert(self.OnEnter, callback)
end

function ButtonComponent:BindToLeave(callback: () -> {})
	table.insert(self.OnLeave, callback)
end

function ButtonComponent:BindToDown(callback: () -> {})
	table.insert(self.OnDown, callback)
end

function ButtonComponent:BindToUp(callback: () -> {})
	table.insert(self.OnUp, callback)
end

function ButtonComponent:BindToDestoy(callback: () -> {})
	table.insert(self.OnDestroy, callback)
end

function ButtonComponent:BindToCallback(name: string, callback: (...any) -> {})
	self.Callbacks[name] = callback
end

function ButtonComponent:OnCallback(name: string, ...: any)
	if (not self.Callbacks[name]) then warn(name..' callback doesnt exist'); return end
	self.Callbacks[name](...)
end

function ButtonComponent.new(guiButton: GuiButton): (typeof(ButtonComponent) & {['Instance']: GuiButton})
	assert(guiButton:IsA('GuiButton'), guiButton.Name..' isnt a GuiButton')
	if (Components[guiButton]) then return Components[guiButton], true end
	
	local self = setmetatable({

		Instance = guiButton,

		OnClick = {},
		OnEnter = {},
		OnLeave = {},

		OnDown = {},
		OnUp = {},
		OnDestroy = {},
		
		Callbacks = {},

	}, ButtonComponent)

	local clickConnection;
	clickConnection = guiButton.MouseButton1Click:Connect(function()
		for _, callback in pairs(self.OnClick) do callback() end
	end)

	local enterConnection;
	enterConnection = guiButton.MouseEnter:Connect(function()
		for _, callback in pairs(self.OnEnter) do callback() end
	end)

	local leaveConnection;
	leaveConnection = guiButton.MouseLeave:Connect(function()
		for _, callback in pairs(self.OnLeave) do callback() end
	end)

	local mouseDownConnection;
	mouseDownConnection = guiButton.MouseButton1Down:Connect(function()
		for _, callback in pairs(self.OnDown) do callback() end
	end)

	local mouseUpConnection;
	mouseUpConnection = guiButton.MouseButton1Up:Connect(function()
		for _, callback in pairs(self.OnUp) do callback() end
	end)


	local destsoyConnection;
	destsoyConnection = guiButton.Destroying:Connect(function()
		clickConnection:Disconnect()
		enterConnection:Disconnect()
		leaveConnection:Disconnect()

		mouseDownConnection:Disconnect()
		mouseUpConnection:Disconnect()
		
		-- !! rewrite into table.clear to avoid leaks
		
		for _, callback in pairs(self.OnDestroy) do callback() end
		
		for _,v in pairs(self) do
			if typeof(v) == "table" then
				table.clear(v)
			end
		end
		
		self.OnClick = nil
		self.OnEnter = nil
		self.OnLeave = nil
		self.OnDown = nil
		self.OnDestroy = nil
		self.OnUp = nil
		self.Callbacks = nil

		setmetatable(self, nil)
		table.clear(self)
		Components[guiButton] = nil

		clickConnection = nil
		enterConnection = nil
		leaveConnection = nil
		mouseDownConnection = nil
		mouseUpConnection = nil

		destsoyConnection:Disconnect()
		self = nil
	end)

	Components[guiButton] = self
	
	return self
end

return ButtonComponent
