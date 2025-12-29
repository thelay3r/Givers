local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild("Components")
local Data = Bricks:WaitForChild("Data")
local _Registries = Data:WaitForChild("Registries")
local Registry = require(_Components.Registry)



local registry = Registry.new()

registry:Register("Root", function()
end)

registry.Inject = {
	"Vault",
}

local ability = {
	Name = "Action.Root",
	Tag = "Main",
	Config = {
		Name = "Run",
		KeyCode = Enum.KeyCode.W,
		CoolDown = 0.1,
		IsActive = false,
		Duration = 1e10,
		MinDuration = 1,
	},
	{
		Name = "Event.OnStart",
		Tag = "OnStart",
		{
			Name = "Condition.CheckBlackList",
			{
				Name = "Action.AcceleratMoveSpeed",
				Tag = "AcceleratMoveSpeed",
				RequestedTags = { ["Owner"] = "Owner", ["Config"] = "Main" },
				Config = {
					Acceleration = 2,
					BaseSpeed = 12,
					AccelerationTime = 0.4,
					Name = "RunSpeedBoost",
				},
			},
			{
				Name = "Action.SetAbilityActive",
				Config = {
					["Status"] = true,
				},
			},
			{
				Name = "Action.SetStatusEffect",
				Config = {
					["Effect"] = "IsRunning",
					["Status"] = true,
				},
			},
			{
				Name = "Action.SetUsed",
			},
			{
				Name = "Condition.CheckVault",
			},
			{
				Name = "NetWork.PlayBindableEvent",
				SendParams = { ["Player"] = { From = "Owner", Path = { "Instance" } } },
				Config = {
					EventName = "PlayVFX",
					VFXType = "Camera.ChangeFOV",
					Client = true,
					EventData = {
						Time = 0.8,
						FOV = 85,
						EasingStyle = Enum.EasingStyle.Sine,
						EasingDirection = Enum.EasingDirection.InOut,
					},
				},
			},
			{
				Name = "Network.PlayBindableEvent",
				InjectParams = { ["Player"] = "Owner.Instance" },
				Config = {
					EventName = "PlayVFX",
					EventData = {
						VFXType = "Animations.Run",
						State = "Start",
						Pack = "Default",
					},
				},
			},
			{
				Name = "NetWork.PlayBindableEvent",
				SendParams = { ["Player"] = { From = "Owner", Path = { "Instance" } } },
				Config = {
					VFXType = "Camera.Woobling",
					Client = true,
					EventData = {
						State = "Start",
						Pack = "Default",
					},
				},
			},
		},

	},
	{
		Name = "Event.OnStop",
		Tag = "OnStop",
		{
			Name = "Condition.IsActive?",
			{
				Name = "Action.DeAcceleratMoveSpeed",
				RequestedTags = { ["Owner"] = "Owner", ["Config"] = "AcceleratMoveSpeed" },
			},
			{
				Name = "NetWork.PlayBindableEvent",
				SendParams = { ["Player"] = { From = "Owner", Path = { "Instance" } } },
				Config = {
					VFXType = "Camera.ChangeFOV",
					Client = true,
					EventData = {
						Time = 0.5,
						FOV = 70,
						EasingStyle = Enum.EasingStyle.Sine,
						EasingDirection = Enum.EasingDirection.InOut,
					},
				},
			},
			{
				Name = "Network.PlayBindableEvent",
				InjectParams = { ["Player"] = "Owner.Instance" },
				Config = {
					EventName = "PlayVFX",
					EventData = {
						VFXType = "Animations.Run",
						State = "Stop",
						Pack = "Default",
					},
				},
			},
			{
				Name = "NetWork.PlayBindableEvent",
				SendParams = { ["Player"] = { From = "Owner", Path = { "Instance" } } },
				Config = {
					EventName = "PlayVFX",
					VFXType = "Camera.Woobling",
					EventData = {
						State = "Stop",
						Pack = "Default",
					},
				},
			},
			{
				Name = "Action.SetAbilityActive",
				Config = {
					["Status"] = false,
				},
			},
			{
				Name = "Action.SetStatusEffect",
				Config = {
					["Effect"] = "IsRunning",
					["Status"] = false,
				},
			},
		},

		
	},
}

return {
	Ability = ability,
	Registry = registry,
}
