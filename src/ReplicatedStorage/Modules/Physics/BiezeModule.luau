local ProximityPromptService = game:GetService("ProximityPromptService")
local BiezeModule = {} -- basic quadratic bezier module forked from somewhere

local AllEasings = {}


AllEasings["Sine"] = {
	["In"] = function(t)
		return 1 - math.cos((t * math.pi) / 2)
	end,
	["Out"] = function(t)
		return math.sin((t * math.pi) / 2)
	end,
	["InOut"] = function(t)
		return -(math.cos(math.pi * t) - 1) / 2
	end
}


AllEasings["Quad"] = {
	["In"] = function(t)
		return t * t
	end,
	["Out"] = function(t)
		return 1 - (1 - t) * (1 - t)
	end,
	["InOut"] = function(t)
		return (t < 0.5) and (2 * t * t) or (1 - math.pow(-2 * t + 2, 2) / 2)
	end
}


AllEasings["Cubic"] = {
	["In"] = function(t)
		return t^3
	end,
	["Out"] = function(t)
		return 1 - (1 - t)^3
	end,
	["InOut"] = function(t)
		return (t < 0.5) and (4 * t^3) or (1 - (-2 * t + 2)^3 / 2)
	end
}


AllEasings["Quart"] = {
	["In"] = function(t)
		return t^4
	end,
	["Out"] = function(t)
		return 1 - (1 - t)^4
	end,
	["InOut"] = function(t)
		return (t < 0.5) and (8 * t^4) or (1 - (-2 * t + 2)^4 / 2)
	end
}


AllEasings["Quint"] = {
	["In"] = function(t)
		return t^5
	end,
	["Out"] = function(t)
		return 1 - (1 - t)^5
	end,
	["InOut"] = function(t)
		return (t < 0.5) and (16 * t^5) or (1 - (-2 * t + 2)^5 / 2)
	end
}


AllEasings["Expo"] = {
	["In"] = function(t)
		return (t == 0) and 0 or math.pow(2, 10 * t - 10)
	end,
	["Out"] = function(t)
		return (t == 1) and 1 or (1 - math.pow(2, -10 * t))
	end,
	["InOut"] = function(t)
		if t == 0 then return 0 end
		if t == 1 then return 1 end
		return (t < 0.5) and (math.pow(2, 20 * t - 10) / 2) or ((2 - math.pow(2, -20 * t + 10)) / 2)
	end
}


AllEasings["Circ"] = {
	["In"] = function(t)
		return 1 - math.sqrt(1 - t^2)
	end,
	["Out"] = function(t)
		return math.sqrt(1 - (t - 1)^2)
	end,
	["InOut"] = function(t)
		return (t < 0.5)
			and ((1 - math.sqrt(1 - (2 * t)^2)) / 2)
			or ((math.sqrt(1 - (-2 * t + 2)^2) + 1) / 2)
	end
}


AllEasings["Back"] = {
	["In"] = function(t)
		local c1, c3 = 1.70158, 1.70158 * 1.525
		return c3 * t^3 - c1 * t^2
	end,
	["Out"] = function(t)
		local c1, c3 = 1.70158, 1.70158 * 1.525
		return 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2
	end,
	["InOut"] = function(t)
		local c1, c2 = 1.70158, 1.70158 * 1.525 * 1.5
		return (t < 0.5)
			and ((math.pow(2 * t, 2) * ((c2 + 1) * 2 * t - c2)) / 2)
			or ((math.pow(2 * t - 2, 2) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2)
	end
}


AllEasings["Elastic"] = {
	["In"] = function(t)
		local c4 = (2 * math.pi) / 3
		return (t == 0) and 0 or ((t == 1) and 1 or -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * c4))
	end,
	["Out"] = function(t)
		local c4 = (2 * math.pi) / 3
		return (t == 0) and 0 or ((t == 1) and 1 or math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1)
	end,
	["InOut"] = function(t)
		local c5 = (2 * math.pi) / 4.5
		if t == 0 then return 0 end
		if t == 1 then return 1 end
		return (t < 0.5)
			and (-(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * c5)) / 2)
			or ((math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * c5)) / 2 + 1)
	end
}


local function bounceOut(t)
	if t < 1 / 2.75 then
		return 7.5625 * t * t
	elseif t < 2 / 2.75 then
		t = t - 1.5 / 2.75
		return 7.5625 * t * t + 0.75
	elseif t < 2.5 / 2.75 then
		t = t - 2.25 / 2.75
		return 7.5625 * t * t + 0.9375
	else
		t = t - 2.625 / 2.75
		return 7.5625 * t * t + 0.984375
	end
end

AllEasings["Bounce"] = {
	["In"] = function(t)
		return 1 - bounceOut(1 - t)
	end,
	["Out"] = function(t)
		return bounceOut(t)
	end,
	["InOut"] = function(t)
		return (t < 0.5)
			and ((1 - bounceOut(1 - 2 * t)) / 2)
			or ((1 + bounceOut(2 * t - 1)) / 2)
	end
}


function BiezeModule.lerp(a,b,t,EasingMode: Enum.EasingStyle?,EasingDirection: Enum.EasingDirection?)
	if (not EasingMode) then return a+(b-a) * t end
	return a+(b-a) * AllEasings[EasingMode.Name][EasingDirection.Name](t)
end

function BiezeModule.elapsedTime(t)
	return 1-(1-2*t)^2
end

function BiezeModule.CreateCurveLerpObject(Object: BasePart,CFG:
	{
		FrameRate: number;
		Frames: number;
		Eeasing: Enum.EasingStyle;
		EasingDirection: Enum.EasingDirection;

		FirstP: Vector3;
		SecondP: Vector3;
		ThirdP: Vector3;

		Cast: boolean;
	})
	
	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = {workspace.Allways.Map}
	Params.FilterType = Enum.RaycastFilterType.Include


	for i=1,CFG.Frames do
		task.wait(CFG.FrameRate)
		local t=i/CFG.Frames
		local lerpProduct = BiezeModule.quadraticBieze(CFG.FirstP,CFG.SecondP,CFG.ThirdP,t)
		local lerpFuture = BiezeModule.quadraticBieze(CFG.FirstP,CFG.SecondP,CFG.ThirdP,t+t)
		if not CFG.Cast then Object.CFrame = CFrame.new(lerpProduct,lerpFuture) continue end
		local cast = workspace:Raycast(lerpProduct+Vector3.new(0,3,0),Vector3.new(0,-10,0),Params)
		local castFuture = workspace:Raycast(lerpFuture+Vector3.new(0,3,0),Vector3.new(0,-10,0),Params)
		if (not cast) or (not castFuture) then continue end
		Object.CFrame = CFrame.new(cast.Position,castFuture.Position) * CFrame.Angles(math.pi,0,0)
		
	end

end

function BiezeModule.quadraticBieze(a,b,c,t,EasingStyle:Enum.EasingStyle,EasingDirection:Enum.EasingDirection)
	local dot1 = BiezeModule.lerp(a,b,t)
	local dot2 = BiezeModule.lerp(b,c,t)
	local finaledot = BiezeModule.lerp(dot1,dot2,t,EasingStyle,EasingDirection)	

	return finaledot
end

return BiezeModule