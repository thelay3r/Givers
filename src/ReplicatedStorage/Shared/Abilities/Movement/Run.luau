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
    };


    {
        Name = 'Event.OnStart';
        Tag = 'OnStart';
        {
            Name = 'Condition.CheckBlackList';
            RequestedTags = {['Owner'] = 'Owner'};

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
                    VFXType = 'Effects.Trail';
                    Client = true;
                    VfxCFG = {
                        State = 'Start';
                        Pack = 'Default';
                        Parent = 'Right Arm'
                    };
                    
                }
            },
            {
                Name = 'NetWork.PlayVFX';
                SendParams = {['Player'] = {From = 'Owner', Path = {'Instance'}}};
                Config = {
                    VFXType = 'Effects.Trail';
                    Client = true;
                    VfxCFG = {
                        State = 'Start';
                        Pack = 'Default';
                        Parent = 'Left Arm'
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
            Name = 'Condition.CheckBlackList';
            RequestedTags = {['Owner'] = 'Owner'};

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