local RunService = game:GetService('RunService')

local Tasks = {
}

local Threads = {
}

local TaskManager = {}

function TaskManager:CreateTask(Object: any, TaskName: string, Time: number, Func: (any) -> ())
	
	Tasks[Object] = Tasks[Object] or {}
	
	if Tasks[Object][TaskName] then
		TaskManager:CancelTask(Object, TaskName)
		warn('Task: '..TaskName..' is Recreated.')
	end
	
	if (Time == nil) or (Time <= 0) then
		Tasks[Object][TaskName] = task.spawn(Func)
	else
		Tasks[Object][TaskName] = task.delay(Time, Func)
	end
	
end

function TaskManager:CancelAllTasks(Object: any)
	if not Tasks[Object] then return end
	for _, Task in pairs(Tasks[Object]) do
		task.cancel(Task)
		Task = nil
	end
end

function TaskManager:CancelTask(Object: any, TaskName: string)

	Tasks[Object] = Tasks[Object] or {}
	
	
	if Tasks[Object][TaskName] then
		task.cancel(Tasks[Object][TaskName])
		Tasks[Object][TaskName] = nil
	end
	
end

function TaskManager:CreateThread(Object: any, TaskName: string, Func: (any) -> ())

	Threads[Object] = Threads[Object] or {}
	
	if Threads[Object][TaskName] then
		TaskManager:CancelThread(Object, TaskName)
	end
	
	Threads[Object][TaskName] = Func
	
end

function TaskManager:CancelAllThreads(Object: any)
	if not Threads[Object] then return end

	for i, Thread in pairs(Threads[Object]) do
		Thread:Disconnect()
		Thread = nil
	end
end

function TaskManager:CancelThread(Object: any, TaskName: string)
	
	if not Threads[Object] then return end
	if not Threads[Object][TaskName] then return end
	
	Threads[Object][TaskName]:Disconnect()
	Threads[Object][TaskName] = nil
	
end

return TaskManager
