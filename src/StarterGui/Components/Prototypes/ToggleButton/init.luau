local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Fusion = require(ReplicatedStorage:WaitForChild('Fusion'))

local Prototypes = script.Parent
local Components = Prototypes.Parent

local ButtonPrototype = require(Components.Prototypes:WaitForChild('Button'))
local scoped = Fusion.scoped

local Styles = require(script.Styles)

local Button = {}

function Button.new(button: GuiButton, styleName: string?)
	local self, isRegistered = ButtonPrototype.new(button, styleName)
	if (isRegistered) then return self end

	local styleData = Styles['Default']
	if (styleName and Styles[styleName]) then styleData = Styles[styleName] end

	local style = TweenInfo.new(1/styleData.Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local scope = scoped(Fusion)

	local movableContainer = button:FindFirstChild('Movable')
	assert(movableContainer, `{button} doesnt have a movable conainer!`)

	local goalPosition = scope:Value(UDim2.fromScale(0, 0))
	--local scaleAnimated2 = scope:Spring(scaleValue, 15, 1)
	local scaleAnimated2 = scope:Tween(goalPosition, style)
	local scaleObserver = scope:Observer(scaleAnimated2)
	
	scaleObserver:onBind(function()
		local value = Fusion.peek(scaleAnimated2)
		movableContainer.Position = value
	end)

	local components = {}

	for _, component in pairs(movableContainer:GetChildren()) do
		if (not component:IsA('GuiButton')) then continue end	
		table.insert(components, component)
		ButtonPrototype.new(component, 'ImmutableButton')
	end

	table.sort(components, function(a0: GuiButton, a1: GuiButton) return a0.LayoutOrder > a1.LayoutOrder end)

	local movableTable = {}
	local offset = -1

	for _, component in pairs(components) do
		local componentOffset = component.Size.X.Scale * movableContainer.Size.X.Scale
		offset += componentOffset
		table.insert(movableTable, {
			Offset = -math.abs(offset),
			Instance = component
		})
	end

	local currentIndex = 1
	
	self:BindToCallback('Swap', function(index: number)
		local selectedElement = movableTable[index]
		if (not selectedElement) then return end

		currentIndex = index
		goalPosition:set(UDim2.fromScale(selectedElement.Offset, movableContainer.Position.Y.Scale))

		self:OnCallback('IndexChanged', currentIndex)
	end)

	self:BindToCallback('Forwards', function()
		self:OnCallback('Swap', (currentIndex%#movableTable)+1)
	end)

	self:BindToCallback('Backwards', function()
		self:OnCallback('Swap', math.max((currentIndex%#movableTable)-1, 1))
	end)
	
	self:BindToClick(function()
		self:OnCallback('Forwards')
	end)

	return self
end

return Button
