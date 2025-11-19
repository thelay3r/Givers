local ValuesInterface = {}

type Setter = (self: any, name: string,value: any) -> ();

export type IAbility = {
	SetAbility: Setter;
}

export type IValues = {
	
		SpecialSet: Setter;
		SetAttribute: Setter;
		SetStatusEffect: Setter;
		SetCharacterData: Setter;
		SetEquipment: Setter;
		SetSetting: Setter;
	}

return ValuesInterface
