local SmoothShiftLock = {};
SmoothShiftLock.__index = SmoothShiftLock;


local Workspace = game:GetService("Workspace");
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService");

local ISmoothShiftLock = require(ReplicatedStorage.Shared.Interfaces.ISmoothShiftLock)
local LocalPlayerInterfaces = require(ReplicatedStorage.Shared.Interfaces.LocalPlayerInterfaces)



local Maid = require(script:WaitForChild("Maid"));
local Spring = require(script:WaitForChild("Spring"));

local LocalPlayer = Players.LocalPlayer;
local PlayerMouse = LocalPlayer:GetMouse();
local Camera = Workspace.CurrentCamera;

local Config = {
	MOBILE_SUPPORT              = false,                     
	SMOOTH_CHARACTER_ROTATION   = true,                       
	CHARACTER_ROTATION_SPEED    = 3,                         
	TRANSITION_SPRING_DAMPER    = 0.7,                        
	CAMERA_TRANSITION_IN_SPEED  = 10,                        
	CAMERA_TRANSITION_OUT_SPEED = 14,                        
	LOCKED_CAMERA_OFFSET        = Vector3.new(1.75, 0.25, 0), 
	LOCKED_MOUSE_ICON           =                             
		"rbxassetid://120299555873250",
	SHIFT_LOCK_KEYBINDS         =                            
		{Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt}
};
--"rbxassetid://102653473143456",

function SmoothShiftLock.CreateSmoothShiftLock(ModedPlayer: LocalPlayerInterfaces.IClientPlayerComponent): ISmoothShiftLock.ISmoothShiftLock
	local self = setmetatable({}, SmoothShiftLock);
	
	self._runtimeMaid = Maid.new();
	self._shiftlockMaid = Maid.new();
	self._cameraOffsetSpring = Spring.new(Vector3.new(0, 0, 0));
	self._cameraOffsetSpring.Damper = Config.TRANSITION_SPRING_DAMPER;
	
	self.ModedPlayer = ModedPlayer
	self.Enabled = false;
	
	self:Enable();
	
	
	return self;
end;

function SmoothShiftLock:Enable()
	self:_refreshCharacterVariables();
	self._runtimeMaid:GiveTask(LocalPlayer.CharacterAdded:Connect(function()
		self:_refreshCharacterVariables();
	end));
	
	ContextActionService:BindActionAtPriority("ShiftLockSwitchAction", function(Name, State, Input)
		return self:_doShiftLockSwitch(Name, State, Input);
	end, Config.MOBILE_SUPPORT, Enum.ContextActionPriority.Medium.Value, unpack(Config.SHIFT_LOCK_KEYBINDS));

	self._runtimeMaid:GiveTask(RunService.RenderStepped:Connect(function(dt)
		if self.Head.LocalTransparencyModifier > 0.6 then return; end;
		
		local CameraCFrame = Camera.CoordinateFrame;
		local Distance = (self.Head.Position - CameraCFrame.p).magnitude;
		if Distance > 1 then
			local LockedPart = self.Torso
			local PositionToPart = (LockedPart.Position - self.RootPart.Position)
			
			
			Camera.CFrame = (Camera.CFrame * CFrame.new(self._cameraOffsetSpring.Position) + PositionToPart); 
			if self.Enabled and UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
				self:_updateMouseState();
			end;
		end;
	end));
end;

function SmoothShiftLock:Disable()
	self._runtimeMaid:DoCleaning();
	self._shiftlockMaid:DoCleaning();
	
	ContextActionService:UnbindAction("ShiftLockSwitchAction");
end;


function SmoothShiftLock:_refreshCharacterVariables()
	self.Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();
	self.Torso = self.Character:WaitForChild("Torso");
	self.RootPart = self.Character:WaitForChild("HumanoidRootPart");
	self.Humanoid = self.Character:WaitForChild("Humanoid");
	self.Head = self.Character:WaitForChild("Head");
end;

function SmoothShiftLock:_doShiftLockSwitch(_, State: Enum.UserInputState)
	if State == Enum.UserInputState.Begin then
		self:ToggleShiftLock();
		return Enum.ContextActionResult.Sink;
	end;

	return Enum.ContextActionResult.Pass;
end;

function SmoothShiftLock:_updateMouseState()
	UserInputService.MouseBehavior = (self.Enabled and Enum.MouseBehavior.LockCenter) or Enum.MouseBehavior.Default;
end;

--// Update the mouse icon
function SmoothShiftLock:_updateMouseIcon()
	PlayerMouse.Icon = (self.Enabled and Config.LOCKED_MOUSE_ICON :: string) or "";
end;

--// Transition the camera to lock offset
function SmoothShiftLock:_transitionLockOffset()
	if self.Enabled then
		self._cameraOffsetSpring.Speed = Config.CAMERA_TRANSITION_IN_SPEED;
		self._cameraOffsetSpring.Target = Config.LOCKED_CAMERA_OFFSET;
	else
		self._cameraOffsetSpring.Speed = Config.CAMERA_TRANSITION_OUT_SPEED;
		self._cameraOffsetSpring.Target = Vector3.new(0, 0, 0);
	end;
end;

--// [ External Functions: ]
function SmoothShiftLock:IsEnabled(): boolean
	return self.Enabled;
end;

--// ShiftLock toggle function
function SmoothShiftLock.ToggleShiftLock(self: ISmoothShiftLock.ISmoothShiftLock, Enable: boolean?)
	if Enable ~= nil then
		self.Enabled = Enable;
	else
		self.Enabled = not self.Enabled;
	end;
	

	self:_updateMouseState();
	self:_updateMouseIcon();
	self:_transitionLockOffset();

	local Attributes = self.ModedPlayer.SessionData.Attributes
	local StatusEffects = self.ModedPlayer.SessionData.StatusEffects
	if self.Enabled then
		self._shiftlockMaid:GiveTask(RunService.RenderStepped:Connect(function(Delta: number)
			if (self.Humanoid and self.RootPart) then 
				self.Humanoid.AutoRotate = not self.Enabled;
			end;
			
			if (self.Humanoid.Sit) or (not StatusEffects.CanAutoRotate) then return; end;
			if Config.SMOOTH_CHARACTER_ROTATION then
				local x, y, z = Camera.CFrame:ToOrientation();
				self.RootPart.CFrame = self.RootPart.CFrame:Lerp(CFrame.new(self.RootPart.Position) * CFrame.Angles(0, y, 0), Delta * 5 * Attributes.AutoRotateSpeed);
			else
				local x, y, z = Camera.CFrame:ToOrientation();
				self.RootPart.CFrame = CFrame.new(self.RootPart.Position) * CFrame.Angles(0, y, 0);
			end;
		end));
	else
		self.Humanoid.AutoRotate = true;
		self._shiftlockMaid:DoCleaning();
	end;
end;

return SmoothShiftLock