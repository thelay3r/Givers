local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')

local BezierCurvesModule = require(ReplicatedStorage:WaitForChild('BezierCurves'))
local RockCreater = require(script.Parent.RockCreater)

local Tasks = {}
local Threads = {}

local Splash = {}

function Splash:Start(args)
	
	local Stones = {}
	
	local Settings = {
		SPAWN_INTERVAL = args.SPAWN_INTERVAL or 0;
		MAX_OBJECTS = args.MAX_OBJECTS or 100;
		LIVE_TIME = args.LIVE_TIME or 3;
		CAN_COLLIDE = args.CAN_COLLIDE or false;
		MIN_SIZE = args.MIN_SIZE or 1;
		MAX_SIZE = args.MAX_SIZE or 1;
		POSITION = args.POSITION;
		
		MIN_XOFFSET = args.MIN_XOFFSET or 0;
		MAX_XOFFSET = args.MAX_XOFFSET or 0;
		
		MIN_YOFFSET = args.MIN_YOFFSET or 0;
		MAX_YOFFSET = args.MAX_YOFFSET or 0;
		
		MIN_ZOFFSET = args.MIN_ZOFFSET or 0;
		MAX_ZOFFSET = args.MAX_ZOFFSET or 0;
		
		DIRECTION = args.DIRECTION;
		HEIGHT = args.HEIGHT or 10;
		DISTANCE = args.DISTANCE or 10;
		IGNORE_LIST = args.IGNORE_LIST or {};
		
		RAY_DIRECTION = args.RAY_DIRECTION or Vector3.one * 5;
		
		BV_STARTY_SPEED = args.BV_STARTY_SPEED or 30;
		BV_START_SPEED = args.BV_START_SPEED or 30;
		
		BV_END_SPEED = args.BV_END_SPEED or 50;
	}
	
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = Settings.IGNORE_LIST
	
	Splash:Vizualise(Settings.POSITION, Settings.DIRECTION, 1)
	
	local result = workspace:Raycast(Settings.POSITION, Settings.DIRECTION, Params)
	
	local function TweenEnding(NewPart)
		if Settings.LIVE_TIME >= 2 then
			Tasks["Transparency"] = task.delay(Settings.LIVE_TIME - 1, function()
				TweenService:Create(NewPart, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()

				for i, v in pairs(NewPart:GetDescendants()) do
					if v:IsA("Texture") or v:IsA("Decal") or v:IsA("Part") or v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("ParticleEmitter") then
						TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end
				end
			end)
		else
			Tasks["Transparency"] = task.delay(0, function()
				TweenService:Create(NewPart, TweenInfo.new(Settings.LIVE_TIME, Enum.EasingStyle.Linear), {
					Transparency = 1
				}):Play()

				for i, v in pairs(NewPart:GetDescendants()) do
					if v:IsA("Texture") or v:IsA("Decal") or v:IsA("Part") or v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("ParticleEmitter") then
						TweenService:Create(v, TweenInfo.new(Settings.LIVE_TIME, Enum.EasingStyle.Linear), {
							Transparency = 1
						}):Play()
					end
				end
			end)
		end
	end
	
	local function Create(Part)
		Tasks['CreateRocks'] = task.spawn(function()
			for number = 1, Settings.MAX_OBJECTS do

				local NewPart = RockCreater.New(Part, workspace.Map.VFXs, true)
				
				local sX = math.random(Settings.MIN_SIZE, Settings.MAX_SIZE)
				local sY = math.random(Settings.MIN_SIZE, Settings.MAX_SIZE)
				local sZ =math.random(Settings.MIN_SIZE, Settings.MAX_SIZE)
				
				local pX = math.random(Settings.MIN_XOFFSET, Settings.MAX_XOFFSET)
				local pY = math.random(Settings.MIN_YOFFSET, Settings.MAX_YOFFSET)
				local pZ = math.random(Settings.MIN_ZOFFSET, Settings.MAX_ZOFFSET)
				
				NewPart.Size = Vector3.new(sX / 10, sY / 10, sZ / 10)
				NewPart.CanCollide = true
				
				NewPart.Position = Settings.POSITION + Vector3.new(pX, pY, pZ)

				NewPart.Rotation = Vector3.new(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))

			   local bv = Instance.new('BodyVelocity', NewPart)
			   bv.MaxForce = Vector3.new(20000, 20000, 20000)
			   bv.Velocity = NewPart.CFrame.LookVector * Settings.BV_START_SPEED + Vector3.new(0, Settings.BV_STARTY_SPEED, 0)
			   
			   task.delay(0.3, function()
					bv.MaxForce = Vector3.new(20000, 0, 20000)
					bv.Velocity = NewPart.CFrame.LookVector * Settings.BV_END_SPEED
			   end)
			   
			   game.Debris:AddItem(bv, 1)

				TweenEnding(NewPart)
				
				game.Debris:AddItem(NewPart, Settings.LIVE_TIME)
				
				if Settings.SPAWN_INTERVAL ~= 0 then
					task.wait(Settings.SPAWN_INTERVAL)
				end
				
			end
		end)
	end
	
	if result.Instance then
		local Part = result.Instance
		
		Create(Part)
		
	end
	
end

function Splash:Vizualise(POSITION: Vector3, DIRECTION: Vector3, Time: number)
	local rSize = (POSITION - DIRECTION).Magnitude
	local center = (POSITION + DIRECTION) / 2
	
	local ray = Instance.new("Part", workspace)
	ray.Size = Vector3.new(1, rSize, 1)
	ray.Position = center
	ray.Material = Enum.Material.SmoothPlastic
	ray.Transparency = 0.5
	ray.Color = Color3.fromRGB(255, 51, 51)
	
	ray.CanCollide = false
	ray.CanQuery = false
	ray.Massless = true
	ray.Anchored = true
	
	local h: Highlight = Instance.new('Highlight', ray)
	h.Adornee = ray
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.FillTransparency = 0.5
	h.FillColor = Color3.fromRGB(255, 0, 0)
	h.OutlineTransparency = 1
	h.Enabled = true
	
	task.delay(Time, function()
		ray:Destroy()
	end)
	
end

return Splash
