export type Data = 
	{
		Name: string;
		Priority: Enum.AnimationPriority;
		_Name: string;
		Events: 
		{
			Name: (any) -> {};
		};
		Settings : 
		{
			['Speed']: number;
			['Weight']: number;
			['FadeTime']: number;
		}
	}

export type TableCache = 
	{
		['track'] : AnimationTrack;
		['Cache'] : {['name'] : AnimationTrack};
	}



export type IAnimationsMethods = {
	Load: (self: IAnimationsComponent, Animation: Animation, Data: Data) -> IAnimationsComponent;
	Get: (self: IAnimationsComponent, Data: Data) -> AnimationTrack;
	GetData: (self: IAnimationsComponent, Data: Data) -> TableCache;
	Set: (self: IAnimationsComponent, track: AnimationTrack,Data: Data) -> ();
	Stop: (self: IAnimationsComponent, Data: Data) -> ();
	IsPlaying: (self: IAnimationsComponent, Data: Data) -> AnimationTrack;
	Play: (self: IAnimationsComponent, Data: Data) -> AnimationTrack;
	Swap: (self: IAnimationsComponent, Data: Data) -> AnimationTrack;
	AdjustSpeed: (self: IAnimationsComponent, Data: Data, speed: number) -> ();
	AdjustWeight: (self: IAnimationsComponent, Data: Data, weight: number) -> ();
	Destroy: (self: IAnimationsComponent) -> ();
	StopByName: (self: IAnimationsComponent,name: string) -> ();
}


export type IAnimationsComponent  = IAnimationsMethods & {
	
	Character: Model;
	Animator: Animator;
	Tracks : 
	{
		['Core']: {};
		['Idle']: {};
		['Movement']: {};
		['Action']: {};
		['Action2']: {};
		['Action3']: {};
	}
}



return {}
