local RunService = game:GetService("RunService")

local Tasks = {
}

local Threads = {
}

local TaskManager = {}

function TaskManager.GetTask(Object: any, TaskName: string)
    Tasks[Object] = Tasks[Object] or {}
    return Tasks[Object][TaskName]
end

function TaskManager.GetThread(Object: any, ThreadName: string)
    Threads[Object] = Threads[Object] or {}
    return Threads[Object][ThreadName]
end

function TaskManager:CreateTask(Object: any, TaskName: string, Time: number, Func: (any) -> ())
    
    Tasks[Object] = Tasks[Object] or {}

    if Tasks[Object][TaskName] then
        TaskManager:CancelTask(Object, TaskName)
        warn('Task: '..TaskName..' is Recreated for.')
    end
    
    if (Time == nil) or (Time <= 0) then
        Tasks[Object][TaskName] = task.spawn(Func)
    else
        Tasks[Object][TaskName] = task.delay(Time, Func)
    end
    
end

function TaskManager:CancelAllTasks(Object: any)
    if not Tasks[Object] then return end
    for name, Task in pairs(Tasks[Object]) do
        TaskManager:CancelTask(Object, name)
    end
end

function TaskManager:CancelTask(Object: any, TaskName: string)
    Tasks[Object] = Tasks[Object] or {}
    
    if Tasks[Object][TaskName] then
        if (Tasks[Object][TaskName] == coroutine.running()) then
            task.defer(function()
                task.cancel(Tasks[Object][TaskName])
                Tasks[Object][TaskName] = nil
            end)
            return
        end
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
        TaskManager:CancelThread(Object, i)
    end
end

function TaskManager.GetAllThreads()
    return Threads
end
function TaskManager.GetAllTasks()
    return Tasks
end
function TaskManager:CancelThread(Object: any, ThreadName: string)
    
    if not Threads[Object] then return end
    if not Threads[Object][ThreadName] then return end
    
    Threads[Object][ThreadName]:Disconnect()
    Threads[Object][ThreadName] = nil
    
end

return TaskManager