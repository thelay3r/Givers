local RollModule = {}

function RollModule:BuildChances(customChances, luckBehavior)
	local adjusted = {}
	
	print(typeof(customChances))
	if typeof(customChances) ~= typeof(table) then
		customChances = {customChances, 100-customChances}
	end
	
	for rarity, chance in pairs(customChances) do
		table.insert(adjusted, {Name = rarity, BaseChance = chance})
	end

	for _, item in ipairs(adjusted) do
		local behaviorData = luckBehavior and luckBehavior[item.Name]
		if behaviorData and typeof(behaviorData) == "table" then
			local mode, multiplier = behaviorData[1], behaviorData[2]

			if mode == "Increase" then
				item.BaseChance *= multiplier
			elseif mode == "Decrease" then
				item.BaseChance /= multiplier
			elseif mode == "Keep" then
				item.BaseChance = item.BaseChance
			end
		end
	end

	local total = 0
	for _, item in ipairs(adjusted) do
		total += item.BaseChance
	end

	for _, item in ipairs(adjusted) do
		item.NormalizedChance = (item.BaseChance / total) * 100
	end

	local cumulative = 0
	local ranges = {}
	for _, item in ipairs(adjusted) do
		local weight = item.NormalizedChance * 1000
		table.insert(ranges, {
			Name = item.Name,
			Min = cumulative + 1,
			Max = cumulative + weight
		})
		cumulative += weight
	end

	return ranges, cumulative
end

function RollModule:Roll(customChances, luckBehavior)
	local ranges, maxRoll = self:BuildChances(customChances, luckBehavior)
	print(customChances)
	local roll = math.random(1, math.floor(maxRoll))
	
	for _, range in ipairs(ranges) do
		if roll >= range.Min and roll <= range.Max then
			return range.Name
		end
	end
	
	return nil
end

function RollModule:DebugChances(customChances, luckBehavior)
	local adjusted = {}

	for rarity, chance in pairs(customChances) do
		table.insert(adjusted, {Name = rarity, BaseChance = chance})
	end

	for _, item in ipairs(adjusted) do
		local behaviorData = luckBehavior and luckBehavior[item.Name]
		if behaviorData and typeof(behaviorData) == "table" then
			local mode, multiplier = behaviorData[1], behaviorData[2]

			if mode == "Increase" then
				item.BaseChance *= multiplier
			elseif mode == "Decrease" then
				item.BaseChance /= multiplier
			elseif mode == "Keep" then
			end
		end
	end

	local total = 0
	for _, item in ipairs(adjusted) do
		total += item.BaseChance
	end

	print("== Debug Chances ==")
	for _, item in ipairs(adjusted) do
		local norm = (item.BaseChance / total) * 100
		print(item.Name .. ": " .. string.format("%.4f", norm) .. "%")
	end
end

return RollModule
