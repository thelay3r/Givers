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
        Name = 'Slide';
        KeyCode = Enum.KeyCode.LeftControl;
        CoolDown = 1;
        IsActive = false;
        Duration = 1e10;
    };
    {
        Name = 'Event.OnStart';
        Tag = 'OnStart';
        {
            Name = 'Condition.CheckBlackList';
            Config = {
                Ignore = {
                    ['IsSliding'] = true;
                }
            };
            {
                Name = 'Condition.RayCheck';
                Tag = 'SlideCheck';
                Config = {
                    Vector = 'UpVector';
                    Range = -5;
                };
                {   Name = 'Ability.SetAbilityActive';
                    Config = 
                    {
                        ['Status'] = true;
                    }
                };
                {
                    Name = 'Ability.SetStatusEffect';
                    Config = 
                    {
                        ['Effect'] = 'IsSliding';
                        ['Status'] = true;
                    }
                };
                {
                    Name = 'Abilities.SlideStart';
                    Tag = 'SlideStart';
                    RequestedTags = {['RayResult'] = 'SlideCheck'};

                    Config = {
                        Delta = 1/10;
                        MaxForce = 35;
                        MaxVelocity = 60;
                        
                        BaseSpeed = 5;
                        MinSpeed = 0;
                        MaxSpeed = 256;
                        SpeedModifier = 1;

                        VerticalDecceleration = 35;
                        VerticalAcceleration = 15; --25
                        HorizontalDecceleration = 15;
                        DefaultSpeed = 5;
                    }
                };
                {
                    Name = 'Abilities.SlideJump';
                    RequestedTags = {['Slide'] = 'SlideStart'};
                };
                {
                    Name = 'NetWork.PlayVFX';
                    Config = {
                            VFXType = 'Animations.Slide';
                            Client = true;
                        VfxCFG = {
                            State = 'Start';
                            Pack = 'Default';
                        };
                    };
                };
                {
                    Name = 'NetWork.PlayVFX';
                    Config = {
                        VFXType = 'Slide.Client';
                        Client = true;
                        VfxCFG = {
                            State = 'Start';
                            Pack = 'Default';
                        };
                    };
                };
            
            }

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
                    ['Effect'] = 'IsSliding';
                    ['Status'] = false;
                }
            };

            {
                Name = 'Abilities.SlideStop';
            };
            {
                Name = 'Ability.SetCoolDown';
            };
            {
                Name = 'NetWork.PlayVFX';
                Config = {
                        VFXType = 'Animations.Slide';
                        Client = true;
                    VfxCFG = {
                        State = 'Stop';
                        Pack = 'Default';
                    };
                };
            };
            {
                Name = 'NetWork.PlayVFX';
                Config = {
                    VFXType = 'Slide.Client';
                    Client = true;
                    VfxCFG = {
                        State = 'Stop';
                        Pack = 'Default';
                    };
                };
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