return 
{
    Name = 'Action.Root';
    Tag = 'Main';
    Config = 
    {
        Name = 'Equip';
        KeyCode = Enum.KeyCode.E;
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
                {   Name = 'Action.SetAbilityActive';
                    Config = 
                    {
                        ['Status'] = true;
                    }
                };
                {
                    Name = 'Action.SetStatusEffect';
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
                        MaxSpeed = 256;
                        SpeedModifier = 1;

                        VerticalDecceleration = 25;
                        HorizontalAcceleration = 15; --25
                        HorizontalDecceleration = 35;
                        DefaultSpeed = 5;
                    }
                };
                {
                    Name = 'Network.PlayVFX';
                    Config = {
                            VFXType = 'Animations.Slide';
                            Client = true;
                        EventData = {
                            State = 'Start';
                            Pack = 'Default';
                        };
                    };
                };
                {
                    Name = 'Network.PlayVFX';
                    Config = {
                        VFXType = 'Slide.Client';
                        Client = true;
                        EventData = {
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
                Name = 'Action.SetAbilityActive';
                Config = 
                {
                    ['Status'] = false;
                }
            };
            {
                Name = 'Action.SetStatusEffect';
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
                Name = 'Network.PlayVFX';
                Config = {
                        VFXType = 'Animations.Slide';
                        Client = true;
                    EventData = {
                        State = 'Stop';
                        Pack = 'Default';
                    };
                };
            };
            {
                Name = 'Network.PlayVFX';
                Config = {
                    VFXType = 'Slide.Client';
                    Client = true;
                    EventData = {
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