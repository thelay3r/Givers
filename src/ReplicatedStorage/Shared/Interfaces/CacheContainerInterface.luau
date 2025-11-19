
local CacheContainerInterface = {}

export type ICache = 
	{
		Container: {[string]: {any}};
		GetInstance: (self: ICache,scope: string,Instance: Instance) -> any;

	}

return CacheContainerInterface
