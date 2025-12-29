local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Templates = Shared:WaitForChild('Templates')

local SpeedInterface = require(Interfaces:WaitForChild('SpeedModuleInterface'))
local SpeedTemplate = require(Templates:WaitForChild('SpeedTemplate'))

type ISpeedComponent = SpeedInterface.SpeedComponent
type ISpeedMethods = SpeedInterface.SpeedMethods
type IDataAmplify = SpeedInterface.IDataAmplify
type IDataRevert = SpeedInterface.IDataRevert

local SpeedController = {}

local Cache = {}

local Methods: ISpeedMethods = {}

function Methods._SetSpeed(self: ISpeedComponent,Speed: number)
	local this_Data = self.Data
	local Humanoid = self.Humanoid
	
	if this_Data.CurrentSpeed == Speed then return end
	Humanoid.WalkSpeed = Speed
	this_Data.CurrentSpeed = Speed
	
	--[[
		Сделай отправку пакетов, на сервер для проверки валидации скорости
		так-же на сервере нужно сделать макс скорость условно 40
		если игрок с клиента кидает скорость > 40 тогда кидаем варн, 5 варнов и кик
		можешь сделать локальную проверку здесь используя пакеты в игроке
		Если скорость больше чем Max устанавливай предыдущие значение скорости
	
	
		arg:
		Speed -> Humanoid.WalkSpeed
		UserId -> Players:GetPlayerByCharacter(Character).UserId
	]]
	
	

end

function Methods._AddToCache(self: ISpeedComponent,Data: IDataAmplify)
	local this_Data = self.Data
	
	this_Data.Cache[Data.Name] = 
		{
			X = -(Data.x);
			InitSpeed = Data.InitSpeed;
			Type = Data._type;
		}
	
	self:_SetSpeed(self.Humanoid.WalkSpeed + Data.x)
	self.Data.CurrentSpeed = self.Humanoid.WalkSpeed
end


function Methods.Amplify(self: ISpeedComponent,Data: IDataAmplify)
	local this_Data = self.Data
	local currentSpeed = if Data.InitSpeed then Data.InitSpeed else this_Data.CurrentSpeed
	local Humanoid = self.Humanoid
	if Data.InitSpeed and Humanoid.WalkSpeed == 0 then return end
	
	local x = math.round((currentSpeed / 100 * Data.Percent)*10)/10
	local _type = if x > 0 then 'Buff' else 'DeBuff'
	if _type == 'DeBuff' then
		local AllBuffes = {}
		for name,v in pairs(this_Data.Cache) do
			self:Revert({Name = name})
		end
		x = math.round((this_Data.CurrentSpeed / 100 * Data.Percent)*10)/10
	end

	Data.x = x
	Data.type = _type
	
	if not this_Data.Cache[Data.Name] then self:_AddToCache(Data) return end
	self:_SetSpeed(Humanoid.WalkSpeed + x)
	this_Data.CurrentSpeed = Humanoid.WalkSpeed
	this_Data.Cache[Data.Name].X -= x;
	
end
function Methods.Revert(self: ISpeedComponent,Data: IDataRevert)
	local this_Data = self.Data
	local Humanoid = self.Humanoid

	if not this_Data.Cache[Data.Name] then return end
	self:_SetSpeed(Humanoid.WalkSpeed + this_Data.Cache[Data.Name].X)
	this_Data.CurrentSpeed = Humanoid.WalkSpeed
	
	table.clear(this_Data.Cache[Data.Name])
	this_Data.Cache[Data.Name] = nil
end

function SpeedController.new(Character: Model) : ISpeedComponent
	if Cache[Character] then return Cache[Character] end
	
	local self: ISpeedComponent = setmetatable(SpeedTemplate(),
	{
		__index = function(t,key)
			return Methods[key] or SpeedController[key]
		end,
	})
	
	self.Character = Character;
	self.Humanoid = Character:FindFirstChildOfClass('Humanoid')
	if not self.Humanoid then return end
	self.Data.DefaultSpeed = self.Humanoid.WalkSpeed
	self.Data.CurrentSpeed = self.Data.DefaultSpeed
	self.Data.LastSpeed = self.Data.CurrentSpeed
	
	
	Cache[Character] = self
	return self
end



return SpeedController
