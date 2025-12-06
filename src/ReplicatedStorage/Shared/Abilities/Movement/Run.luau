return 
{
    Name = 'Action.Root';
    Tag = 'Main';
    Config = 
    {
        Name = 'Run';
        KeyCode = Enum.KeyCode.W;
        CoolDown = .1;
        IsActive = false;
        Duration = 1e10;
    };
    {
        Name = 'Event.OnStart';
        Tag = 'OnStart';
        {
            Name = 'Condition.CheckBlackList';
            {
                Name = 'Action.AcceleratMoveSpeed';
                Tag = 'AcceleratMoveSpeed';
                RequestedTags = {['Owner'] = 'Owner',['Config'] = 'Main'};
                Config = 
                {
                    
                    Acceleration = 2;
                    BaseSpeed = 12;
                    AccelerationTime = .4;
                    Name = 'RunSpeedBoost';
                }
            };
            {
                Name = 'Ability.SetAbilityActive';
                Config = 
                {
                    ['Status'] = true;
                }
            };
            {
                Name = 'Ability.SetStatusEffect';
                Config = 
                {
                    ['Effect'] = 'IsRunning';
                    ['Status'] = true;
                }
            };
            {
                Name = 'Ability.SetCoolDown';
            };
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {['Player'] = {From = 'Owner', Path = {'Instance'}}};
                Config = {
                    VFXType = 'Camera.ChangeFOV';
                    Client = true;
                    VfxCFG = {
                        Time = .8;
                        FOV = 85;
                        EasingStyle = Enum.EasingStyle.Sine;
                        EasingDirection = Enum.EasingDirection.InOut;
                    };
                    
                },
            },
              {
                Name = 'NetWork.PlayVFX';
                SendParams = {['Player'] = {From = 'Owner', Path = {'Instance'}}};
                Config = {
                    VFXType = 'Animations.Run';
                    Client = true;
                    VfxCFG = {
                        State = 'Start';
                        Pack = 'Default';
                    };
                }
            },
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {['Player'] = {From = 'Owner', Path = {'Instance'}}};
                Config = {
                    VFXType = 'Camera.Woobling';
                    Client = true;
                    VfxCFG = {
                        State = 'Start';
                        Pack = 'Default';
                    };
                    
                }
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
                    ['Effect'] = 'IsRunning';
                    ['Status'] = false;
                }
            };
            {
                Name = 'Action.DeAcceleratMoveSpeed';
                RequestedTags = {['Owner'] = 'Owner',['Config'] = 'AcceleratMoveSpeed'};
            };
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {['Player'] = {From = 'Owner', Path = {'Instance'}}};
                Config = {
                    VFXType = 'Camera.ChangeFOV';
                    Client = true;
                    VfxCFG = {
                        Time = .5;
                        FOV = 70;
                        EasingStyle = Enum.EasingStyle.Sine;
                        EasingDirection = Enum.EasingDirection.InOut;
                    };
                    
                }
            },
             {
                Name = 'NetWork.PlayVFX';
                SendParams = {['Player'] = {From = 'Owner', Path = {'Instance'}}};
                Config = {
                    VFXType = 'Animations.Run';
                    Client = true;
                    VfxCFG = {
                        State = 'Stop';
                        Pack = 'Default';
                    };
                    
                }
            },
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {['Player'] = {From = 'Owner', Path = {'Instance'}}};
                Config = {
                    VFXType = 'Camera.Woobling';
                    Client = true;
                    VfxCFG = {
                        State = 'Stop';
                        Pack = 'Default';
                    };
                    
                }
            }
        }
    }
}