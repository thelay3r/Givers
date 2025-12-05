return 
{
    Name = 'Action.Root';
    Tag = 'Main';
    Config = 
    {
        Name = 'Dash';
        KeyCode = Enum.KeyCode.Q;
        CoolDown = .1;
        IsActive = false;
    };

    {
        Name = 'Event.OnStart';
        Tag = 'OnStart';
        {
            Name = 'Condition.CheckBlackList';
            {
                Name = 'Ability.SetAbilityActive';
                Config = 
                {
                    ['Status'] = true;
                };
            };
            {
                Name = 'Action.GetDashDirection';
                Tag = 'DashDirection';
                RequestedTags = {['Owner'] = 'Owner'};

            };
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {
                    ['DashConfig'] = {From = 'DashDirection'};
                    ['Player'] = {From = 'Owner', Path = {'Instance'}}
                };
                Config = 
                {
                    VFXType = 'Animations.Dash';
                    Client = true;
                    VfxCFG = {
                        State = 'Start';
                        Pack = 'Default';
                    };
                };
            };
            {
                Name = 'Action.BodyVelocity';
                SendParams = {
                    ['DashConfig'] = {From = 'DashDirection'};
                    ['Parent'] = {From = 'Owner', Path = {'Instance','Character','HumanoidRootPart'}}
                };
                Tag = 'BodyVelocityDash';
                Config = 
                {
                    BodyVelocity = 
                    {
                            P = 15000;
                            MaxForce = Vector3.new(15000,0,15000);
                            Priority = 1;
                            Speed = 50;
                            DestroyTime = .35
                    };
                };
                {
                    Name = 'Action.SmoothBodyVelocity';
                    RequestedTags = {['BodyVelocity'] = 'BodyVelocityDash'};

                    Config = 
                    {
                        SPoint = 1.2;
                        EPoint = 0;
                        FrameRate = 1/60;
                        TotalTime = .35;
                    };
                }
            };
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
            },
        }
    }
}