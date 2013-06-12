require 'date'
require 'terminal-notifier'

require_relative '../db/task'
require_relative '../db/task_time'
require_relative '../views/dialog'
require_relative '../config/bugdata'


class Bugger

    def bug(action)
        task_time = TaskTime.last

        if task_time.idle?
            puts 'We have been idle'
            task_time.end 
            register_idle_time
        elsif task_time.downtime?
            puts 'We have been down'            
            task = prompt_for_task(task_time)
            task_time.end(task_time.last_update)
            TaskTime.start(task.id)  
        elsif action == 'notify'
            show_notification(task_time)
            task_time.touch
        else            
            task = prompt_for_task(task_time) 
            if task_time.task_id != task.id
                task_time.end
                TaskTime.start(task.id)
            else
                task_time.touch
            end
        end
    end

    def show_notification(task_time)
        callback = BugData.config.ruby_bin + " " + File.dirname(__FILE__) + "/../bugadm prompt" 
        title = "Time spent on task today: " + task_time.time_spent 
        task = Task.by_id(task_time.task_id)
        TerminalNotifier.notify(task.name, :title => title, :execute => callback)        
    end

    def prompt_for_task(task_time)
        text = "Time spent on current task: #{task_time.time_spent}" 
        title = "Bugger - What are you working on?"
        last_task = Task.by_id(task_time.task_id)
        task_name = BugDialog.prompt_for_task(title, text, last_task.name)
        Task.by_name(task_name)
    end

    def register_idle_time()
        idle_start=Time.now
        text = "You have been idle since: #{idle_start.strftime('%H:%M')}"
        title = "Bugger - What were you doing?"
        task_name = BugDialog.prompt_for_task(title, text, '')
        task = Task.by_name(task_name)
        TaskTime.start(task.id, idle_start)
    end            

end

