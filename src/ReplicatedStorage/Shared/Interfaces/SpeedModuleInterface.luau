
local SpeedModuleInterface = {}


export type IDataAmplify =
	{
		Name: string;
		InitSpeed: number;
		Percent: number;
	};
export type IDataRevert =
	{
		Name: string;
		Recursive: boolean;
	};

export type SpeedMethods = 
	{
		new: (Character: Model) -> SpeedComponent;
		Amplify:(self: SpeedComponent,Data: IDataAmplify)-> ();
		Revert:(self: SpeedComponent,Data: IDataRevert) ->();
		_AddToCache:(self: SpeedComponent,Data:IDataAmplify)-> ();
		_SetSpeed:(self: SpeedComponent,speed: number)->();
		
	}

export type SpeedComponent = SpeedMethods &
	{
		Character: Model;
		Humanoid: Humanoid;
		Data: 
		{
			CurrentSpeed: number;
			LastSpeed: number;
			DefaultSpeed: number;
			
			Cache: 
			{
				[string] : 
				{
					['X'] : number;
					['Type']: string;
				}
			}
		}
	}

return SpeedModuleInterface
