local StarterGui = game:GetService('StarterGui')
local TweenService = game:GetService('TweenService')

local Backpack = {}

local KeyCodes = 
	{
		[Enum.KeyCode.One.Name] = 1;
		[Enum.KeyCode.Two.Name] = 2;
		[Enum.KeyCode.Three.Name] = 3;
		[Enum.KeyCode.Four.Name] = 4;
		[Enum.KeyCode.Five.Name] = 5;
		[Enum.KeyCode.Six.Name] = 6;
		[Enum.KeyCode.Seven.Name] = 7;
		[Enum.KeyCode.Eight.Name] = 8;
		[Enum.KeyCode.Nine.Name] = 9;
		[Enum.KeyCode.Zero.Name] = 10;
		[Enum.KeyCode.Minus.Name] = 11;
		[Enum.KeyCode.Equals.Name] = 12;
		[Enum.KeyCode.Backquote.Name] = -1;
	}

local Typing = 
	{
		[11] = "-";
		[12] = "=";
	}

return Backpack
