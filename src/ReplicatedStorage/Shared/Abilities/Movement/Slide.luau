return 
{
    Name = 'Action.Root';
    Tag = 'Main';
    Config = 
    {
        Name = 'Slide';
        KeyCode = Enum.KeyCode.LeftControl;
        CoolDown = .5;
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
                    Name = 'Abilities.SlideJump';
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
                        MaxSpeed = 100;
                        SpeedModifier = 1;

                        VerticalDecceleration = 25;
                        HorizontalAcceleration = 15; --25
                        HorizontalDecceleration = 225;
                        DefaultSpeed = 5;
                    }
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
                Name = 'Condition.ResumeRun?'
            }
        }
    }
}