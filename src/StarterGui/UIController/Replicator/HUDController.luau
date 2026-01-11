local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local UIUtilities = require(StarterGui.Components.UIUtilities)
local LocalPlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.LocalPlayerInterfaces)
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)

type PlayerComponent = LocalPlayerInterfaces.IClientPlayerComponent

local mainUI: typeof(StarterGui.MainUI);
local playerComponent: PlayerComponent;

local function changeHealthBar()
    local hud = mainUI.UI.HUD
    local healthHUD = hud.HealthBar
    local container = healthHUD.container
    local healthbar = container.bar

    if (not healthbar) then return end

    local character = playerComponent.ClientData.CharacterData.Character
    if (not character) then return end

    local humanoid = character.Humanoid :: Humanoid
    if (not humanoid) then return end

    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    local healthPercent = health / maxHealth

    UIUtilities:TweenBarTransparencyGradient(healthbar, healthPercent, .3)
    --healthbar.Position = UDim2.fromScale(healthPercent-1, .5)
end

local OldPosture= 0
local function changePosturehBar()
    local hud = mainUI.UI.HUD
    local postureHUD = hud.PostureBar

    local leftContainer = postureHUD.leftContainer
    local rightContainer = postureHUD.rightContainer

    local leftBar = leftContainer.bar
    local rightBar = rightContainer.bar

    

    if (not leftBar) then return end
    if (not rightBar) then return end

    local leftBlur= leftBar.blur
    local rightBlur= rightBar.blur

    local character = playerComponent.ClientData.CharacterData.Character
    if (not character) then return end

    local humanoid = character.Humanoid :: Humanoid
    if (not humanoid) then return end

    local posture = playerComponent.SessionData.Attributes.Posture :: number
    local maxPosture = playerComponent.SessionData.Attributes.MaxPosture :: number
    local posturePercent = posture / maxPosture
    


    TweenService:Create(leftBar, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromScale(math.clamp(1-posturePercent, 0, 1), 0)}):Play()
    TweenService:Create(rightBar, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromScale(math.clamp(posturePercent-1, -1, 0), 0)}):Play()
    
    

    if OldPosture >= posturePercent then
        OldPosture = posturePercent
        return
    end
    OldPosture = posturePercent

    TweenService:Create(leftBlur, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
    TweenService:Create(rightBlur, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
    
    TaskManager:CreateTask(character, 'blurVisible', 1, function(a0)  
        TweenService:Create(leftBlur, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
        TweenService:Create(rightBlur, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
    end)

end

return function(UI: typeof(StarterGui.MainUI), component: PlayerComponent)
	mainUI = UI
    playerComponent = component

    changeHealthBar()
    changePosturehBar()

    warn('-- HUD Initialized --')

    component.Buses.Character:Subscribe("OnHealthChanged", function()
        changeHealthBar()
    end)

    component.Replica:OnChange(function(method,path)
        if (#path < 3) or (path[3] ~= 'Posture') then return end
        print(path[3])
        changePosturehBar()
    end)
end
