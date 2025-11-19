local Emit = {}

function Emit:Emit(Object: Part)
	
	for _,emitter:ParticleEmitter? in pairs(Object:GetDescendants()) do
			local delayStr = emitter:IsA("Sound") and "Delay" or "EmitDelay"

			local emitDelay = tonumber(emitter:GetAttribute(delayStr)) or 0
			local emitCount = tonumber(emitter:GetAttribute('EmitCount')) or tonumber(emitter.Name) or 0
			local emitDuration = tonumber(emitter:GetAttribute('EmitDuration')) or 0

			task.delay(emitDelay, function()
				if emitter:IsA('ParticleEmitter') then
					emitter:Emit(emitCount)
				elseif emitter:IsA('PointLight') then
					emitter.Enabled = true
				end	

				if emitter:IsA("Sound") then
					emitter:Play()
				end

				if emitDuration > 0 then
					task.defer(function()
					emitter.Enabled = true
					task.wait(emitDuration)
					emitter.Enabled = false
				end)
			end
		end)
	end
end

return Emit
