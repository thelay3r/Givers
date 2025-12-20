local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')
local TaskManager = require(ReplicatedStorage.Shared.Utilities.Modules.TaskManager)
local Registry = require(_Components.Registry)



local registry = Registry.new()


registry:Register('Vaulting', function(self,node)
	local Owner = self.Tags['Owner']
	local _Instance = Owner.Instance
	local Character = _Instance.Character :: Model
	local RootPart = Character:FindFirstChild('HumanoidRootPart'):: BasePart
	local raycast = node.Additional['RayResult']['RayResult']
	if not raycast then return end
	local rayInstance = raycast.Instance :: BasePart
	if not rayInstance:HasTag('Vault') then return end
	rayInstance.CanCollide = false 

	Character:FindFirstChildOfClass('Humanoid').JumpPower = 0

	self:Execute(
		{
			Name = 'Action.DestroyBodyVelocity';
			Config = {
				Part = 'HumanoidRootPart'
			}
		})
	self:Execute(
		{
			Name = 'Action.BodyVelocity';
			Config = 
			{
				MaxForce = Vector3.one * 15000;
				P = 15000;
				DestroyTime = .2;
				Velocity = RootPart.CFrame.LookVector * 25 + RootPart.CFrame.UpVector * 10;
				Parent = RootPart;
			};
		})
	TaskManager:CreateTask(node, 'CanCollideOff', .3, function(a0)
		rayInstance.CanCollide = true 
		Character:FindFirstChildOfClass('Humanoid').JumpPower = 50
	end)
end)

local ability = {
        Name = 'Action.Root';
        Tag = 'Main';
        Config = 
        {
            Name = 'Vault';
            KeyCode = Enum.KeyCode.Space;
            CoolDown = .5;
            IsActive = false;
            Duration = .4;
        };
        {
            Name = 'Event.OnStart';
            Tag = 'OnStart';
            {
                Name = 'Condition.CheckBlackList';
                Config = {
                ['Ignore'] = { ['IsVaulting'] = true};
                    };
                {
                    Name = 'Condition.RootRayCheck';
                    Tag = 'VaultRay';
                    Config = 
                    {
                        Range = 5;
                    };
                    {
                        Name = 'Ability.SetAbilityActive';
                        Config = 
                            {
                                ['Status'] = true;
                            };
                    },
                    {
                        Name = 'Ability.SetCoolDown';
                    };
                    {
                        Name = 'Action.Vaulting';
                        RequestedTags = {['RayResult'] = 'VaultRay'}
                    };
                    {
                        Name = 'NetWork.PlayVFX';
                        Config = 
                        {
                            VFXType = 'Animations.Vault';
                            Client = true;
                            EventData = {
                                State = 'Start';
                                Pack = 'Default';

                            };
                        };
                    
                };
                {
                        Name = 'Ability.SetStatusEffect';
                        Config = 
                        {
                            ['Effect'] = 'IsVaulting';
                            ['Status'] = true;
                        }
                    };

                };

            }
        };
        {
            Name = 'Event.OnStop';
            Tag = 'OnStop';
            {
                Name = 'Condition.IsActive?';
                RequestedTags = {['Ability'] = 'Main'};
                {
                    Name = 'Ability.SetAbilityActive';
                    Config = 
                    {
                        ['Status'] = false;
                    }
                };
                {
                    Name = 'Ability.SetStatusEffect';
                    Config = 
                    {
                        ['Effect'] = 'IsVaulting';
                        ['Status'] = false;
                    }
                };
                {
                    Name = 'Condition.ResumeRun?'
                }
            }
        }

}

return {
    Ability = ability;
    Registry = registry;

}