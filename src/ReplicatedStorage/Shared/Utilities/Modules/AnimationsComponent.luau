local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')

local AnimationsInterfaces = require(Interfaces:WaitForChild('AnimationsInterfaces'))
local AnimationTemplate = require(Templates:WaitForChild('Animations'))

local AnimationComponent = {}
local Methods = {}

local Animators = {}

type IAnimation = AnimationsInterfaces.IAnimationsComponent
type IData = AnimationsInterfaces.Data
type ITrack = AnimationsInterfaces.TableCache

function Methods.Stop(self: IAnimation, Data: IData)
	local track: AnimationTrack = self:Get(Data)
	if not track then return end
	track:Stop()
end

function Methods.Swap(self: IAnimation, Data: IData)
	
	local trackData = self:GetData(Data)
	
	local currentTrack = trackData.track
	if not currentTrack then return end
	local archivedTrack: AnimationTrack = trackData.Cache[Data._Name]
	if not archivedTrack then return end
	
	local Speed = (Data.Settings and Data.Settings.Speed) or 1
	local FadeTime = (Data.Settings and Data.Settings.FadeTime) or .1
	local Weight = (Data.Settings and Data.Settings.Weight) or 1
	
	archivedTrack.Priority = Data.Priority

	currentTrack:Stop()
	archivedTrack:Play(FadeTime,Weight,Speed)
	

	trackData.track = archivedTrack
	return archivedTrack
end

function Methods.Play(self: IAnimation, Data: IData)
	local track = self:Get(Data)
	if not track then return end
	
	local Speed = (Data.Settings and Data.Settings.Speed) or 1
	local FadeTime = (Data.Settings and Data.Settings.FadeTime) or .1
	local Weight = (Data.Settings and Data.Settings.Weight) or 1

	track.Priority = Data.Priority
	track:Play(FadeTime,Weight,Speed)
	
	if not Data.Events then return track end
	for name,func in pairs(Data.Events) do
		track:GetPropertyChangedSignal(name):Once(func)
	end
	
	return track
end

function Methods.Set(self: IAnimation,track: AnimationTrack, Data: IData)
	local trackData: ITrack = self:GetData(Data)
	local _tracks = self.Tracks

	if trackData then
		self:Stop(Data)
		trackData.track = track
		trackData.Cache[Data._Name] = track
	else
		_tracks[Data.Priority][Data.Name] = 
			{
				['track'] = track;
				['Cache'] = 
				{
					[Data._Name] = track
				};
			}
	end
	
	return self
end

function Methods.GetData(self: IAnimation, Data: IData)
	if not self.Tracks then return false end
	if not self.Tracks[Data.Priority] then return false end
	if not self.Tracks[Data.Priority][Data.Name] then return false end

	return self.Tracks[Data.Priority][Data.Name]
end

function Methods.AdjustSpeed(self: IAnimation,Data,speed)
	local track: AnimationTrack = self:Get(Data)
	if not track then return end
	track:AdjustSpeed(speed)
end
function Methods.AdjustWeight(self: IAnimation,Data,weight)
	local track: AnimationTrack = self:Get(Data)
	if not track then return end
	track:AdjustWeight(weight)
end

function Methods.IsPlaying(self: IAnimation, Data: IData) : AnimationTrack
	local track: AnimationTrack = self:Get(Data)
	if not track then return end
	return track.IsPlaying
end

function Methods.Get(self: IAnimation, Data: IData) : AnimationTrack
	if not self.Tracks[Data.Priority][Data.Name] then return end
	return self.Tracks[Data.Priority][Data.Name].track
end

function Methods.Destroy(self: IAnimation)
	
	for _,v in pairs(self.Tracks) do
		for _,j: ITrack in pairs(v) do
			j.track:Stop()
			j.track:Destroy()
			j.track = nil
			for _,k in j.Cache do
				k:Stop()
				k:Destroy()
				k = nil
			end
			table.clear(j.Cache)
		end
	end
	
	Animators[self.Character] = nil
	table.clear(self.Tracks)
	self.Tracks = nil
	self.Character = nil
	self.Animator = nil
	
	
	self = setmetatable({},nil)
	table.clear(self)
	self = nil
end

function Methods.StopByName(self: IAnimation,_name)
	for index,v in pairs(self.Tracks) do
		for name,j in pairs(v) do
			if name ~= _name then continue end
			self:Stop(
				{
					Name = _name;
					Priority = index
				})
		end
	end			
end

function Methods.Load(self: IAnimation,Animation: AnimationTrack, Data) : IAnimation
	local Cached = self:GetData(Data)
	local track
	if Cached then
		if Cached.Cache[Data._Name] then
			track = Cached.Cache[Data._Name]
			return self,Data
		end
	end
		
	local track = self.Animator:LoadAnimation(Animation)
	Data.LoadedAnimation = Animation
	self:Set(track,Data)
	
	return self,Data
end


function AnimationComponent.new(Character: Model) : IAnimation
	if Animators[Character] then return Animators[Character] end
	print(Animators)
	local self: IAnimation = setmetatable(AnimationTemplate(),
		{
			__index = function(t,key)
				return Methods[key]
			end,
		})
	
	
	local Humanoid: Humanoid? = Character:FindFirstChildOfClass('Humanoid')
	if not Humanoid then return end
	local Animator: Animator? = Humanoid:FindFirstChildOfClass('Animator')
	if not Animator then return end
	
	self.Character = Character
	self.Animator = Animator
	

	
	Animators[Character] = self
	return self
end


return AnimationComponent