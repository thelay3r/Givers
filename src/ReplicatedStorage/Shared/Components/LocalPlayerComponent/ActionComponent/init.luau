local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Shared = ReplicatedStorage:WaitForChild('Shared')
local Interfaces = Shared:WaitForChild('Interfaces')
local Components = Shared:WaitForChild('Components')
local Utilities = Shared:WaitForChild('Utilities')
local UtilModules = Utilities:WaitForChild('Modules')
local NetWork = Utilities:WaitForChild('NetWork')
local Packets = require(NetWork:WaitForChild('Packets'))

local LocalPlayerInterfaces = require(Interfaces:WaitForChild('LocalPlayerInterfaces'))

local ContextActionService = game:GetService('ContextActionService')
local UserInputService = game:GetService('UserInputService')

local TaskManager = require(UtilModules:WaitForChild('TaskManager'))

local Contexts = require(script.Contexts)

type ILocalPlayer = LocalPlayerInterfaces.IClientPlayerComponent

local ActionComponent = {}

function ActionComponent:FormattedInput(input)
	local FormattedInput = tostring(input.KeyCode.Name)

	if input.KeyCode == Enum.KeyCode.Unknown then
		FormattedInput = tostring(input.UserInputType.Name)
	end


	return FormattedInput
end

function ActionComponent:FormattedState(input)
	local FormattedState = tostring(input.UserInputState.Name)

	return FormattedState
end

function ActionComponent.UpdateControls(self, actions: {Codes: {}, States: {}, Name: string})
	ContextActionService:UnbindAction('CriticalControls')
	
	local codes = {}
	
	
	for _, info in pairs(actions) do
		for i, code in pairs(info.Codes) do
			table.insert(codes, code)
		end
	end

	
	
	ContextActionService:BindAction('CriticalControls', 
		function(actionName, inputState: Enum.UserInputState, inputObject)
			
			local selectedActions = {};
			local FormatedInput = self:FormattedInput(inputObject)
			for _, action in pairs(actions) do
				if inputObject.KeyCode == Enum.KeyCode.Unknown then continue end
				if (table.find(action.States, inputState)) and (table.find(action.Codes, inputObject.KeyCode)) then
					table.insert(selectedActions, action)
				end
			end
			
			for _, action in pairs(actions) do
				if inputObject.UserInputType == Enum.UserInputType.Keyboard then continue end
				if (table.find(action.States, inputState)) and (table.find(action.Codes, inputObject.UserInputType)) then
					table.insert(selectedActions, action) 
					break
				end
			end
			
			if (#selectedActions < 1) then return end
			
			for _, action in pairs(selectedActions) do
				if (not Contexts[action.Name]) then continue end
				Contexts[action.Name](action, inputState, FormatedInput)
			end
			
			return Enum.ContextActionResult.Pass
			
		end, false, table.unpack(codes))
end

function ActionComponent.ReplicateKeys(self: ILocalPlayer)
	
	TaskManager:CreateThread(self,'InputBeganRK', UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		local FormattedInput = ActionComponent:FormattedInput(input)
		local FormattedState = ActionComponent:FormattedState(input)
		
		self.ClientData.PressedKeys[FormattedInput] = FormattedInput
		
		Packets.ReplicateKeys:Fire({Key = FormattedInput, State = FormattedState})
	end))
	
	TaskManager:CreateThread(self,'InputEndedRK',UserInputService.InputEnded:Connect(function(input, gpe)
		if gpe then return end
		local FormattedInput = ActionComponent:FormattedInput(input)
		local FormattedState = ActionComponent:FormattedState(input)
		self.ClientData.PressedKeys[FormattedInput] = nil
		Packets.ReplicateKeys:Fire({Key = FormattedInput, State = FormattedState})
	end))
	
end


return ActionComponent
