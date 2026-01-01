--[[local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Utitlites = Shared:WaitForChild('Utilities')
local NetWork = Utitlites:WaitForChild('NetWork')

local SharedComponents = Shared:WaitForChild('Components')

local LocalPlayer = game.Players.LocalPlayer
local Character: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid: Humanoid = Character:WaitForChild('Humanoid')

local PlayerBackPack = LocalPlayer.Backpack

local PlayerGui = LocalPlayer.PlayerGui
local StarterGui = game:GetService('StarterGui')

local Replicator = require(NetWork:WaitForChild("Replicator"))
local Components = PlayerGui:FindFirstChild('Components')
local Prototypes = Components.Prototypes

local ToolInterfaces = require(Interfaces:WaitForChild('ToolInterfaces'))
local UIInterfaces = require(Interfaces:WaitForChild('UIInterfaces'))

local LocalPlayerComponent = require(SharedComponents:WaitForChild('LocalPlayerComponent'))
local ToolComponent = require(SharedComponents:WaitForChild('ToolComponent'))
local ButtonPrototype: UIInterfaces.ButtonPrototype = require(Prototypes:FindFirstChild('HotbarButton'))

local UIButtonComponent = require(Components:WaitForChild('UIButtonComponent'))
local UIFrameComponent = require(Components:WaitForChild('UIFrameComponent'))

local mainUI: typeof(StarterGui.Interface);

local backpackButtons = {}

local backpackInstances = {}
local tools = {}

local Tasks = {}
local Threads = {}

local ActiveSlots = 0

local MinDistance = 100
local IsInventoryOpen = false

local Busy = false;
local CoolDown = false
local CoolDownTime = .2

local Player = LocalPlayerComponent:GetPlayer()

local function TagManipulator(Tool: ToolInterfaces.IToolComponents, TagName: string, Time: number)
	Tool.Instance:AddTag(TagName)
	if Time ~= math.huge then
		task.delay(Time, function()
			Tool.Instance:RemoveTag(TagName)
		end)
	elseif Time == 0 then
		Tool.Instance:RemoveTag(TagName)
	else
		task.delay(Time, function()
			Tool.Instance:RemoveTag(TagName)
		end)
	end
end

local function DefaultSelectButton(button, UIbutton: GuiButton, Tool: ToolInterfaces.IToolComponents)
	button.Selected = not button.Selected
	button.Object:OnCallback('OnSelect', button.Selected)
	if button.Selected then
		TagManipulator(Tool, 'Moving')
		Humanoid:EquipTool(Tool.Instance)
	else
		TagManipulator(Tool, 'Moving', 0.1)
		Tool.Instance.Parent = LocalPlayer.Backpack
	end
	
	for i, otherButton in pairs(backpackButtons) do
		if (otherButton.Object.Instance.LayoutOrder == UIbutton.LayoutOrder) then continue end
		otherButton.Selected = false
		otherButton.Object:OnCallback('OnDeselect')

	end
	
end

local function DeSelectButton(button, UIbutton: GuiButton, Tool: ToolInterfaces.IToolComponents)

	Player = LocalPlayerComponent:GetPlayer()

	if not Tool.Equipped then return end

	if not Player.ClientData[Tool.Config.Storage][Tool.Config.Scope][Tool.Config.Name] then return end
	local Ability = Player.ClientData[Tool.Config.Storage][Tool.Config.Scope][Tool.Config.Name]

	if button.Object.Threads['Duration'] then
		button.Object.Threads['Duration']:Disconnect()
	end

	if os.clock() - Action.LastUsed < Action.MinDuration then
		task.delay(Action.LastUsed + Action.MinDuration - os.clock(), function()
			button.Selected = false
			button.Object:OnCallback('OnDeselect')
			TagManipulator(Tool, 'Moving')
			Tool.Instance.Parent = LocalPlayer.Backpack
			Busy = false
		end)
	else
		button.Selected = false
		button.Object:OnCallback('OnDeselect')
		TagManipulator(Tool, 'Moving')
		Tool.Instance.Parent = LocalPlayer.Backpack
		Busy = false
	end
end

local function SelectButton(button, UIbutton: GuiButton, Tool: ToolInterfaces.IToolComponents)
	
	Player = LocalPlayerComponent:GetPlayer()
	
	if Tool.Equipped then return end
	
	if not Player.ClientData[Tool.Config.Storage][Tool.Config.Scope][Tool.Config.Name] then return end
	local Ability = Player.ClientData[Tool.Config.Storage][Tool.Config.Scope][Tool.Config.Name]
	
	if (os.clock() - Action.LastUsed) <= Action.Cooldown then return end
	
	Busy = true
	
	button.Object.Threads['Duration'] = RunService.Heartbeat:Connect(function()
		if (os.clock() - Action.LastUsed) >= Action.Duration then 
			DeSelectButton(button, UIbutton, Tool)
			if button.Object.Threads['Duration'] then
				button.Object.Threads['Duration']:Disconnect()
			end
		end
	end)
	
	button.Selected = true
	button.Object:OnCallback('OnSelect', button.Selected)
	TagManipulator(Tool, 'Moving')
	Humanoid:EquipTool(Tool.Instance)

	for i, otherButton in pairs(backpackButtons) do
		if (otherButton.Object.Instance.LayoutOrder == UIbutton.LayoutOrder) then continue end
		otherButton.Selected = false
		otherButton.Object:OnCallback('OnDeselect')

	end
end

local function FindClosestSlot(guiButton: GuiButton)

	local backpackUI = mainUI.Inventory.HotBar
	local MinMagnitude = 9e9
	local selectedUI;

	for _, v: GuiButton in ipairs(backpackUI.Container:GetChildren()) do
		if (not v:IsA('GuiButton')) then continue end
		local Magnitude = math.round((guiButton.AbsolutePosition - v.AbsolutePosition).Magnitude)

		if (Magnitude > MinDistance) then continue end

		if Magnitude < MinMagnitude then 
			MinMagnitude = Magnitude 
			selectedUI = v
		end
	end

	return selectedUI
end

local function SetupInventoryButton(UIbutton: GuiButton)

	local button =  {
		Object = ButtonPrototype.new(UIbutton);
		Selected = false;
	}

	button.Object:OnCallback('OnInventoryChange')
	backpackButtons[UIbutton.LayoutOrder] = button

	button.Object:BindToCallback('SelectedSlot', function(State: Enum.UserInputState)
		
		local Tool: ToolInterfaces.IToolComponents = tools[button.Object.Instance.LayoutOrder]
		
		if not Busy then
			if Tool.Config.Type == 'Ability' then
				if State == Enum.UserInputState.Begin then
					SelectButton(button, UIbutton, Tool)
				elseif State == Enum.UserInputState.End then
					DeSelectButton(button, UIbutton, Tool)
				end
			else
				DefaultSelectButton(button, UIbutton, Tool)
			end
		end

	end)

	button.Object:BindToDown(function()
		if (not IsInventoryOpen) then button.Object:OnCallback('SelectedSlot', Enum.UserInputState.Begin) return end
		local item = button.Object.Instance:FindFirstChild('item') :: GuiButton
		if not item then return end

	end)

	button.Object:BindToUp(function()
		if (not IsInventoryOpen) then
			
			local Tool: ToolInterfaces.IToolComponents = tools[button.Object.Instance.LayoutOrder]
			
			if Tool.Config.Type == 'Ability' then
				button.Object:OnCallback('SelectedSlot', Enum.UserInputState.End)
			end
			return
		end
	end)

end

local function SetupInventoryButtons()

	local backpackUI = mainUI.Inventory.HotBar

	for _, v: GuiButton in ipairs(backpackUI.Container:GetChildren()) do
		if (not v:IsA('GuiButton')) then continue end

		SetupInventoryButton(v)
	end

	Replicator:GetRemote('BindableGlobal'):Connect('BackPackGUI',function(Int, State)
		local button = backpackButtons[Int]
		if (IsInventoryOpen) or not button.Object.Instance:FindFirstChild('item') then return end
		
		local Tool: ToolInterfaces.IToolComponents = tools[button.Object.Instance.LayoutOrder]
		
		if State == Enum.UserInputState.Begin then
			button.Object:OnCallback('SelectedSlot', State)
		elseif State == Enum.UserInputState.End then
			if Tool.Config.Type == 'Ability' then
				button.Object:OnCallback('SelectedSlot', State)
			end
		end
		
	end)

end

local function CreateItemSlot(child: Tool)
	
	local Tool = ToolComponent.new(child, LocalPlayer)
	
	if backpackInstances[child] then return end
	
	local backpackUI = mainUI.Inventory.HotBar
	local slot  = backpackUI.Templates.Slot

	local Templates = backpackUI.Templates

	local NewSlot = Templates.item:Clone()
	local selectedParent = backpackUI

	local defaultSize = UDim2.fromOffset(slot.AbsoluteSize.X, slot.AbsoluteSize.Y)

	for i, v: GuiButton in ipairs(backpackUI.Container:GetChildren()) do
		if (not v:IsA('GuiButton')) then continue end
		if (v:FindFirstChild('item')) then continue end

		NewSlot.Interactable = false
		selectedParent = v
		defaultSize = UDim2.fromScale(1,1)
		break
	end

	NewSlot.ToolName.Text = Tool.Instance.Name
	NewSlot.Size = defaultSize
	NewSlot.Parent = selectedParent
	
	backpackInstances[child] = NewSlot
	tools[selectedParent.LayoutOrder] = Tool
end

local function SetupBackpack()

	local backpackUI = mainUI.Inventory.HotBar
	local Templates = backpackUI.Templates

	for _,v in pairs(PlayerBackPack:GetChildren()) do
		if not v:IsA('Tool') then continue end
		CreateItemSlot(v)
	end

	PlayerBackPack.ChildAdded:Connect(function(child: Tool)
		if child:HasTag('Moving') then child:RemoveTag('Moving') return end
		CreateItemSlot(child)
	end)

	PlayerBackPack.ChildRemoved:Connect(function(child: Tool)
		if (not backpackInstances[child]) then return end
		if child:HasTag('Moving') then Character:RemoveTag('Moving') return end
		backpackInstances[child]:Destroy()
		backpackInstances[child] = nil
	end)

end

return function(UI: typeof(StarterGui.MainUI))
	mainUI = UI
	
	SetupBackpack()
	SetupInventoryButtons()
	
end]]

return function (UI)
	
end