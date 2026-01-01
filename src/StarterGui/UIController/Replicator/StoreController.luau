local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Utitlites = ReplicatedStorage:WaitForChild("Utilities")

local LocalPlayer = game.Players.LocalPlayer :: Player
local PlayerBackPack = LocalPlayer.Backpack

local PlayerGui = LocalPlayer.PlayerGui
local StarterGui = game:GetService("StarterGui")

local OrderedInfo = require(ReplicatedStorage.Info.OrderedInfo)
local Replicator = require(Utitlites:WaitForChild("Replicator"))
local Components = PlayerGui:FindFirstChild('Components')
local Prototypes = Components.Prototypes

local Info = ReplicatedStorage.Info
local Templates = ReplicatedStorage.Templates

local Interfaces = ReplicatedStorage:WaitForChild("Interfaces")
local MainUI = require(Interfaces:WaitForChild("MainUI"))
local UIInterfaces = require(Interfaces:WaitForChild("UIInterfaces"))
local PlayerInterfaces = require(Interfaces:WaitForChild("PlayerInterfaces"))

local ButtonPrototype: UIInterfaces.ButtonPrototype = require(Prototypes:FindFirstChild("Button"))
local MovableFramePrototype = require(Prototypes:FindFirstChild("MovableFrame"))
local ResizableFramePrototype = require(Prototypes:FindFirstChild("ResizableFrame"))

local UIButtonComponent = require(Components:WaitForChild('UIButtonComponent'))
local UIFrameComponent = require(Components:WaitForChild('UIFrameComponent'))

local Enums = require(Templates.Enums)
local CarTemplate = require(Templates.CarTemplate)
local CarInfo = require(Info.CarInfo)

local GlobalEvent = Replicator:GetRemote('Global')
local BindableGlobal = Replicator:GetRemote('BindableGlobal')

type ICarTemplate = typeof(CarTemplate())

local mainUI: MainUI.Main
local replica;

--[[
data[3400996587] = {name = 'testpass', producttype = Enums.ProductType.DevProduct, price = 100}

data[3458266145] = {name = 'coins1', producttype = Enums.ProductType.DevProduct, price = 100}
data[3458266368] = {name = 'coins2', producttype = Enums.ProductType.DevProduct, price = 100}
data[3458266711] = {name = 'coins3', producttype = Enums.ProductType.DevProduct, price = 100}
data[3458266806] = {name = 'coins4', producttype = Enums.ProductType.DevProduct, price = 100}
data[3458267040] = {name = 'coins5', producttype = Enums.ProductType.DevProduct, price = 100}

data[3458267327] = {name = 'limited1', producttype = Enums.ProductType.DevProduct, price = 100}

data[1587710969] = {name = 'vip', producttype = Enums.ProductType.Gamepass, price = 100}
data[1587547119] = {name = 'unlockmaps', producttype = Enums.ProductType.Gamepass, price = 100}
data[1587373220] = {name = 'x2money', producttype = Enums.ProductType.Gamepass, price = 100}
data[1587672989] = {name = 'starterpack', producttype = Enums.ProductType.Gamepass, price = 100}

]]

local products = {
    ['coins_1'] = 3458266145,
    ['coins_2'] = 3458266368,
    ['coins_3'] = 3458266711,
    ['coins_4'] = 3458266806,
    ['coins_5'] = 3458267040,

    ['VIP'] = 1587710969,
    ['AllMaps'] = 1587547119,
    ['x2Money'] = 1587373220,

    ['StarterPack'] = 1587672989,
    ['Limited1'] = 3458267327,
}

local function PromptProduct(key)
    local selectedInfo = products[key]
    if (not selectedInfo) then warn(`product {key} isnt registered on the client`); return end 
    GlobalEvent:Fire('MarketPurchased', selectedInfo)
end

local function SetupGamepasses()
    local center = mainUI.Screen.MainFrame.Center
    local store = center.Store.ScrollingFrame

    for _, object: Instance in pairs(store.Passes.Container:GetChildren()) do
        if (not object:IsA('GuiButton')) then continue end
        ButtonPrototype.new(object, 'ShopButton'):BindToClick(function(button)
            PromptProduct(object.Name)
        end)
    end
end

local function SetupCoins()
    local center = mainUI.Screen.MainFrame.Center
    local store = center.Store.ScrollingFrame


    ButtonPrototype.new(store.Coins.Container['coins_5'], 'ShopButton'):BindToClick(function()
        PromptProduct('coins_5')
    end)

    for _, object: Instance in pairs(store.Coins.Container.OtherDeals:GetChildren()) do
        if (not object:IsA('GuiButton')) then continue end
        ButtonPrototype.new(object, 'ShopButton'):BindToClick(function()
            PromptProduct(object.Name)
        end)
    end
end

local function UpdateLimiteds()
    local center = mainUI.Screen.MainFrame.Center
    local store = center.Store.ScrollingFrame

    store.Limited.Container.Car.Stock.Text = OrderedInfo.GlobalValues.Limited1..'/'..OrderedInfo.ImmutableGlobalValues.Limited1
end

local function SetupLimiteds()
    local center = mainUI.Screen.MainFrame.Center
    local store = center.Store.ScrollingFrame

    local productName = 'Limited1'

    ButtonPrototype.new(store.Limited.Container, 'ShopButton'):BindToClick(function()
        PromptProduct(productName)
    end)

    ButtonPrototype.new(store.Limited.Container.Buy, 'ShopButton'):BindToClick(function()
        PromptProduct(productName)
    end)
end

local function SetupShop()
    local center = mainUI.Screen.MainFrame.Center
    local left = mainUI.Screen.MainFrame.Left
    local top = mainUI.Screen.MainFrame.Top

    local buttons = left.Buttons
    local store = center.Store

    ButtonPrototype.new(buttons.Store):BindToClick(function()
        MovableFramePrototype.new(store):Change()
        MovableFramePrototype.new(store):CloseOthers()
    end)   

    ButtonPrototype.new(store.Title.Close):BindToClick(function()
        MovableFramePrototype.new(store):Close()
    end)

    ButtonPrototype.new(top.Buttons.Counters.DriftCoins.Buy):BindToClick(function()
        MovableFramePrototype.new(store):Open()
        TweenService:Create(store.ScrollingFrame, TweenInfo.new(.5, Enum.EasingStyle.Quad), {
            CanvasPosition = Vector2.new(0, store.ScrollingFrame.AbsoluteCanvasSize.Y)
        }):Play()
    end)

    SetupGamepasses()
    SetupCoins()
    SetupLimiteds()
end

return function(UI: typeof(StarterGui.MainUI), component: PlayerInterfaces.IPlayerClientComponent)
	mainUI = UI
    replica = component.Replica

    SetupShop()
    UpdateLimiteds()

    BindableGlobal:Connect('GlobalValuesChanged', function()
        UpdateLimiteds()
    end)
end
