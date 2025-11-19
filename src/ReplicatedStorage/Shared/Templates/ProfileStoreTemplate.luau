return {
	Values = {
		['Gold'] = 0;
		['Level'] = 1;
	};
	
	Multipliers = {
		['Damage'] = 1;
		['DamageResistance'] = 1;
		['Health'] = 1;
		
		['Luck'] = 1;
	};
	
	Equipment = {
		['Style'] = 'Fists';
		['Weapon'] = 'none';
		['Armor'] = 'none';
	};
	
	Config = {
		FirstJoin = os.time();
		LastJoin = os.time();
		
		DayAmount = 0;
		IngameTime = 0;
		
		Donated = 0;
	};
	
	Products = {};
	Items = {};

	Constants = {
		VERSION = 0.1
	};
	
}