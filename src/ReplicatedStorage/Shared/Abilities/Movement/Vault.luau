local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bricks = ReplicatedStorage.Bricksv2

local _Components = Bricks:WaitForChild('Components')
local Data = Bricks:WaitForChild('Data')
local _Registries = Data:WaitForChild('Registries')
local Registry = require(_Components.Registry)



local registry = Registry.new()

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
                            VfxCFG = {
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