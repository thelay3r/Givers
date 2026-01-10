local TweenService = game:GetService('TweenService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Fusion = require(ReplicatedStorage:WaitForChild('Fusion'))

local Prototypes = script.Parent
local Components = Prototypes.Parent

local UIFrameComponent = require(Components:WaitForChild('UIFrameComponent'))
local scoped = Fusion.scoped

local Frame = {}

local function createDotFrame(frame: Frame)
    local component = UIFrameComponent.new(frame)

    local tweenInfo = TweenInfo.new(.5)

    component:BindToOpen(function()
        TweenService:Create(frame, tweenInfo, {
            Transparency = 1,
            Rotation = 30,
        }):Play()
    end)

    component:BindToClose(function()
        TweenService:Create(frame, tweenInfo, {
            Transparency = 0,
            Rotation = 0,
        }):Play()
    end)

    return component
end

function Frame.new(frame: Frame, styleName: string?)
	local self, isRegistered = UIFrameComponent.new(frame)
	if (isRegistered) then return self end
	
    local uiList = Instance.new('UIListLayout')
    uiList.VerticalFlex = Enum.UIFlexAlignment.Fill
    uiList.FillDirection = Enum.FillDirection.Horizontal
    uiList.HorizontalFlex = Enum.UIFlexAlignment.Fill
    uiList.Padding = UDim.new(0)

    uiList.Parent = frame

    local matrix = {10, 10}
    local frames = {}

    local scaleX = matrix[1] * frame.Size.X.Scale
    local scaleY = matrix[2] * frame.Size.Y.Scale

    for _ = 1, matrix[1]*matrix[2] do
        local dotFrame = Instance.new('Frame')
        dotFrame.Size = UDim2.fromScale(scaleX, scaleY)
        dotFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
        dotFrame.Parent = frame

        local component = createDotFrame(dotFrame)

        table.insert(frames, component)
    end
	
    self:BindToOpen(function()
        for _, frame in frames do
            frame:Open()
            task.wait()
        end
    end)

    self:BindToClose(function()
        for _, frame in frames do
            task.wait()
        end
    end)

	return self
end

return Frame
