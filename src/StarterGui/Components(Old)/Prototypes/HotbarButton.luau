local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Shared = ReplicatedStorage:WaitForChild('Shared')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')

local Static = Shared:WaitForChild('Static')

local Fusion = require(UtilModules:WaitForChild('Fusion'))
local EffectStatuc = require(Static:WaitForChild('EffectStatic'))

local Prototypes = script.Parent
local Components = Prototypes.Parent

local UIButtonComponent = require(Components:WaitForChild('UIButtonComponent'))
local scoped = Fusion.scoped

local Button = {}

function Button.new(guiButton: GuiButton)
	local self, isRegistered = UIButtonComponent.new(guiButton)
	if (isRegistered) then return self end
	
	local defaultSelectorColor = Color3.fromRGB(255, 255, 255)
	local defaultOnEnterColor = Color3.fromRGB(255, 255, 255)

	local defaultSelectorTransparency = 0
	local defaultSize = 0.76
	local defaultMulti = .2
	
	local stroke = guiButton:FindFirstChildWhichIsA('UIStroke', true)
	local size = guiButton:FindFirstChildWhichIsA('UIScale')
	
	local scope = scoped(Fusion)
	local style = TweenInfo.new(.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

	defaultSelectorColor = stroke.Color
	defaultSelectorTransparency = stroke.Transparency

	local onEnterColor = stroke:FindFirstChildWhichIsA('Color3Value')
	if (onEnterColor) then defaultOnEnterColor = onEnterColor.Value end

	size.Scale = defaultSize

	local isResized = false
	local isSelected = false
	
	local scaleValue = scope:Value(defaultSize)
	local strokeValue = scope:Value(1)
	local scaleValueTween = scope:Value(defaultSize)
	
	local strokeAnimated = scope:Tween(strokeValue, style)
	local scaleAnimated2 = scope:Spring(scaleValue, 15, 0.5)
	local scaleTweenAnimation = scope:Tween(scaleValueTween,style)
	

	local strokeObserver = scope:Observer(strokeAnimated)
	local scaleObserver = scope:Observer(scaleAnimated2)
	local scaleTweenObserver = scope:Observer(scaleTweenAnimation)
	
	scaleTweenObserver:onBind(function()
		local value = Fusion.peek(scaleTweenAnimation)
		size.Scale = value
		
		local status = (size.Scale < .01) and true or false
		guiButton.Visible = not status
	end)
	
	scaleObserver:onBind(function()
		if (isResized) then return end
		local value = Fusion.peek(scaleAnimated2)

		size.Scale = value
	end)

	strokeObserver:onBind(function()
		local value = Fusion.peek(strokeAnimated)
		stroke.Transparency = value
	end)

	self:BindToCallback('OnInventoryChange',function()
		if guiButton:FindFirstChild('item') then return end
		
		isResized = not isResized
		local value = isResized and 0 or defaultSize
		
		scaleValueTween:set(value)
	end)
	
	self:BindToCallback('OnSelect', function(bool)
		scaleAnimated2:addVelocity(-5)
		if (bool) then 
			strokeValue:set(1)
			scaleValue:set(defaultSize * (1+defaultMulti))
			isSelected = true
			EffectStatuc['PlayInterfaceSound']('Interface', 'Click')
			return 
		end
		self:OnCallback('OnDeselect')
	end)
	
	self:BindToCallback('OnDeselect', function()
		strokeValue:set(1)
		if (not isSelected) then return end
 
		isSelected = false
		scaleValue:set(defaultSize)
		EffectStatuc['PlayInterfaceSound']('Interface', 'Click')
	end)

	self:BindToEnter(function()
		EffectStatuc['PlayInterfaceSound']('Interface', 'Hover')
		if (isSelected) then return end
		scaleValue:set(defaultSize * (1+defaultMulti))
	end)

	self:BindToLeave(function()
		if (isSelected) then return end
		scaleValue:set(defaultSize)
	end)

	return self
end

return Button
