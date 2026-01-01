local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService("UserInputService")

local Utitlites = ReplicatedStorage:WaitForChild("Utilities")
local Interfaces = ReplicatedStorage:WaitForChild("Interfaces")

local Fusion = require(ReplicatedStorage:WaitForChild('Fusion'))

local Prototypes = script.Parent
local Components = Prototypes.Parent

local UIButtonComponent = require(Components:WaitForChild('UIButtonComponent'))
local Replicator = require(Utitlites:WaitForChild("Replicator"))

local UIInterfaces = require(Interfaces:WaitForChild("UIInterfaces"))

local scoped = Fusion.scoped

local Button = {}

local DragSpeed = 2
local Friction = .95
local MaxRotation = 40
local MinMagnitude = 40

local BindableEvent = Replicator:GetRemote("BindableGlobal")

function Button.new(guiButton: GuiButton): UIInterfaces.ButtonComponent
	local self, isRegistered = UIButtonComponent.new(guiButton)
	if (isRegistered) then return self end
	
	local MousePos = UserInputService:GetMouseLocation()
	local MouseDown = UserInputService:GetMouseButtonsPressed()
	
	local DragButton = self.Instance
	local IsActive = false
	local wasDragged = false
	
	local isLocked = false
	
	local LastFramePosition = DragButton.Position
	local CurrentFramePosition
	
	local scope = scoped(Fusion)
	
	local positionValue = scope:Value(UDim2.fromScale(0,0))
	local scaleValue = scope:Value(1)
	
	local scaleAnimated2 = scope:Spring(positionValue, 15, 0.25)
	local scaleAnimated = scope:Spring(scaleValue, 15, 0.25)
	
	local scaleObserver2 = scope:Observer(scaleAnimated2)
	local scaleObserver = scope:Observer(scaleAnimated)
	
	local size = guiButton:FindFirstChildWhichIsA('UIScale')
	
	scaleObserver2:onBind(function()
		local value = Fusion.peek(scaleAnimated2)
		if (not isLocked) then return end
		print(value)
		guiButton.Position = value
		--if (guiButton.Position.X.Offset < 1) then test = false end
	end)
	
	scaleObserver:onBind(function()
		local value = Fusion.peek(scaleAnimated)
		size.Scale = value
	end)
	
	self:BindToCallback('Test1', function()
		scaleAnimated2:setPosition(guiButton.Position)
		isLocked = true
		positionValue:set(UDim2.new(0,0,0,0))
		
		task.wait(2)
		
		isLocked = false
	end)
	
	self:BindToCallback('ChangeSize', function()
		scaleValue:set(1)
		wasDragged = true
	end)
	
	self:BindToCallback('UnbindDraggable', function()
		RunService:UnbindFromRenderStep('Draggable')
	end)
	
	local connection = BindableEvent:Connect("MouseInput",function(status: boolean)
		--print("MOUSE EVENT")
		if (status == "OnStart") or (not IsActive) then return end
		self:OnCallback('OnMouseUp')
		
		IsActive = false
	end)
	
	self:BindToCallback("StartDrag",function()
		self:OnCallback('ChangeParent')
		
		IsActive = true
		
		MousePos = UserInputService:GetMouseLocation()
		DragButton.Position = UDim2.fromOffset(MousePos.X, MousePos.Y)
		
		RunService:BindToRenderStep('Draggable', 10, function()
			MousePos = UserInputService:GetMouseLocation()

			CurrentFramePosition = DragButton.Position
			local Lerp = DragButton.Position:Lerp(UDim2.fromOffset(MousePos.X - (DragButton.AbsoluteSize.X/2),MousePos.Y - (DragButton.AbsoluteSize.Y/2)),.25)

			local deltaX = CurrentFramePosition.X.Offset - LastFramePosition.X.Offset

			DragButton.Rotation = math.clamp(-deltaX*DragSpeed*Friction,-MaxRotation,MaxRotation)
			DragButton.Position = Lerp

			LastFramePosition = CurrentFramePosition

			--print(Lerp)
		end)
	end)
	
	self:BindToDown(function()
		print('Started Dragging')
		
		self:OnCallback("StartDrag")
	end)
	
	self:BindToDestoy(function()
		local connections = BindableEvent:GetConnections("MouseInput")
		local result = table.find(connections, connection)
		
		if (result < 1) then return end
		table.remove(connections, result)
	end)
	
	self:BindToEnter(function()
		scaleValue:set(1)
	end)
	
	self:BindToLeave(function()
		scaleValue:set(wasDragged and 1 or .9)
		wasDragged = false
	end)
	
	return self
end

return Button