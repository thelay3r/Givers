export type IBodyVelocity = {
	Instance: {
		Parent: Instance;
		Velocity: Vector3;
		MaxForce: Vector3;
		Priority: number;
	};
	
	Settings: {
		Swap: {
			Toggle: boolean;
			FinalVector: Vector3;
			WaitTime: number;
			SmoothTime: number;
		};

	    DestroyTime: number?;
    };
}

export type ITrail = {
	Propertis: {
		Instance: Part;
		Parent: any;
		C0: CFrame;
		C1: CFrame;
		
	};
	Settings: {
		ChangeLifeTime: number;
		LifeTime: number;
		DisableTime: number;
		DestroyTime: number;
	}
}

return {}