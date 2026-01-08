local TableHelper = {}

function TableHelper:LoadModules(Modules : {})
	
	local _table = {}
	
	for _,v in pairs(Modules) do
		_table[v.Name] = require(v)
	end
	return _table
end

function TableHelper:DeepTableClone(t : {})
	local newTable = {}
	
	for index, value in pairs(t) do
		if type(value) == type(table) then
			newTable[index] = TableHelper:DeepTableClone(value)
		else
			newTable[index] = value
		end
		
	end
	
	return newTable
end

function TableHelper:CheckCycleTable(firstTable : {}, secondTable : {})
	
	for index, value in pairs(secondTable) do
		if firstTable[index] and firstTable[index] == value then return false end
	end

	return true
	
end
function TableHelper:CheckIndexCount(t : {})
	if t == nil then return 0 end
	local count = 0
	for _,v in pairs(t) do
		count += 1
	end

	return count
end

function TableHelper:DeepTableFind2(_table: {}, Target: any, Type: string?, ignorElements: {})
    ignorElements = ignorElements or {}
    
    if ignorElements[_table] then
        return nil
    end
    ignorElements[_table] = true
    
    for index, value in pairs(_table) do
        if index == Target then
            if not Type or typeof(value) == Type then
                return value
            end
        end
        
        if value == Target then
            if not Type or typeof(value) == Type then
                return value
            end
        end
        
        if typeof(value) == "table" then
            local result = TableHelper:DeepTableFind(value, Target, Type, ignorElements)
            if result ~= nil then
                return result
            end
        end
    end
    
    return nil
end

function TableHelper:DeepTableFind(_table : {},Type : any, Target : any, ignorElements : {})
	
	if not ignorElements then
		ignorElements = {}
	end

	local target



	for index, value in pairs(_table) do
		if not TableHelper:CheckCycleTable({[index] = value},ignorElements) then continue end
		ignorElements[index] = value
		if target then
			if not Type then
				return target
			else
				if typeof(target) == Type then
					return target
				end
			end
		end
		if typeof(value) == "table" then
			if index == Target then
				target = value
			else
				target = TableHelper:DeepTableFind(value,Target,Type,ignorElements)
			end
		else
			if index == Target then
				target = value
			end
		end	
	end
	return target
end

function TableHelper:CheckDeepTalbeClone(OldTable : {}, OriginTable : {})
	warn(OriginTable)
	
	for index,value in pairs(OriginTable) do
		
		if type(value) == "table" then
			if not OldTable[index] then
				OldTable[index] = {}
				OldTable[index] = TableHelper:CheckDeepTalbeClone(OldTable[index],value)
			else
				OldTable[index] = TableHelper:CheckDeepTalbeClone(OldTable[index],value)
			end
		else
			if not OldTable[index] then
				OldTable[index] = value
			end
		end
	end
	

	
	return OldTable
end

return TableHelper

--[[ПРИМЕР ДОПУСТИМ ХИТБОКС УЛОВИЛ ТРЕХ ЕБАНАТОВ ТО ИНФА СКОЛЬКО УРОНА ДОЛЖЕН КТО ПОЛУЧИТЬ ОНА КАК-БЫ ОБЩАЯ
И ЕСЛИ У ОДНОГО ИГРОКА РЕЗИСТ 50% НА УРОН И У ВТОРОГО УСЛОВНЫЕ 10% ТО ДЕМАДЖ СНИЗИТСЯ НА 50% ПРИ КОСАНИИ ПЕРВОГО А ПОТОМ ЭТОТ ДЕМАДЖ СНИЗИТСЯ
ЕЩЕ НА 10% И ПО ИТОГУ ТВОИ 10 УРОНА ПРЕВРАТЯТЬСЯ В 4.5 ДЛЯ ВТОРОГО А ДЛЯ ПЕРВОГО 5 А ЭТА ШТУКА ПОМОГАЕТ СДЕЛАТЬ ТАК ЧТО-БЫ ВТОРОЙ ЧЕЛ ПОЛУЧИЛ 10 - 10%
ТОЕСТЬ 9 УРОНА В ЗАМЕН 4.5

ПРИМЕР 

OnHit(info)

info.Damage = 5

retunr info
end

function TakeDamage(dealer,info)

    local OriginalInfo = TableHelper:DeepTableClone(info)
    for _,v in pairs(self.Passives) do

     v.OnHit(self,dealer,OriginalInfo)
  
    end


end

]]