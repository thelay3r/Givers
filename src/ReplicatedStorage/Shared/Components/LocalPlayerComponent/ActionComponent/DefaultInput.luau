local AdService = game:GetService("AdService")
return {
	[1] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.One};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End}; -- Используем таблицу
		Additional = { Int = 1 };
	};

	[2] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Two};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 2 };
	};

	[3] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Three};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 3 };
	};

	[4] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Four};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 4 };
	};

	[5] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Five};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 5 };
	};

	[6] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Six};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 6 };
	};

	[7] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Seven};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 7 };
	};

	[8] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Eight};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 8 };
	};

	[9] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Nine};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 9 };
	};

	[0] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Zero};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 10 };
	};

	['-'] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Minus};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 11 };
	};

	['='] = {
		Name = 'BackpackButton';
		Codes = {Enum.KeyCode.Equals};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = { Int = 12 };
	};

	['Movement'] = {
		Name = 'Movement';
		Codes = {Enum.KeyCode.W, Enum.KeyCode.Q, Enum.KeyCode.Space, Enum.UserInputType.MouseButton2};
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = {
			[Enum.KeyCode.W.Name] = {Name = 'Sprint', Type = 'Both'},
			[Enum.KeyCode.Q.Name] = {Name = 'Dash', Type = 'Client'},
			[Enum.UserInputType.MouseButton2.Name] = {Name = 'Feint', Type = 'Client'},
			[Enum.KeyCode.Space.Name] = {Name = 'Vault', Type = 'Client'},
		};
	};

	['Abilities'] = 
	{
		Name = 'Ability';
		Codes = {
			Enum.KeyCode.Z,
			Enum.KeyCode.X,
			Enum.KeyCode.C,
			Enum.KeyCode.V,

			Enum.UserInputType.MouseButton1,
			Enum.KeyCode.E,
			Enum.KeyCode.F
			},
		States = {Enum.UserInputState.Begin, Enum.UserInputState.End};
		Additional = {};
	};
	['LocalAbilities'] = 
	{
		Name = 'LocalAbility';
		Codes = {
			Enum.KeyCode.W;
			Enum.KeyCode.Q;
			Enum.KeyCode.LeftControl;
		};
	}
	
	
}