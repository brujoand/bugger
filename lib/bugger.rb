#! /usr/bin/env ruby

require 'date'
require 'terminal-notifier'

require_relative '../db/task'
require_relative '../db/task_time'
require_relative '../config/config'
require_relative '../views/dialog'


class Bugger

    def bug(action)
        task_time = TaskTime.last

        if idle?
            task_time.end 
            prompt_for_idle_time
        elsif task_time.downtime?
              task_time.end_at(task_time.last_update)
              task = prompt_for_task(task_time)
              TaskTime.start(task.id)  
        elsif action == 'notify'
            show_notification(task_time)
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
        callback = CONFIG['ruby_bin'] + " " + File.dirname(__FILE__) + "/../bugadm prompt" 
        title = "Time spent on task today: " + task_time.time_spent 
        task = Task.by_id(task_time.task_id)
        TerminalNotifier.notify(task.name, :title => title, :execute => callback)
        task_time.touch
    end

    def prompt_for_task(task_time)
        text = "Time spent on current task: #{task_time.time_spent}" 
        title = "Bugger - What are you working on?"
        last_task = Task.by_id(task_time.task_id)
        task_name = BugDialog.prompt_for_task(title, text, last_task.name)
        Task.by_name(task_name)
    end

    def prompt_for_idle_time()
        idle_start=Time.now
        text = "You have been idle since: #{idle_start.strftime('%H:%M')}"
        title = "Bugger - What were you doing?"
        task_name = BugDialog.prompt_for_task(title, text, '')
        task = Task.by_name(task_name)
        TaskTime.start_from(task.id, idle_start)
    end

    def idle?()
        idle_time=%x(echo $(($(ioreg -c IOHIDSystem | sed -e '/HIDIdleTime/!{ d' -e 't' -e '}' -e 's/.* = //g' -e 'q') / 1000000000))).to_i
        if idle_time > 300
            true
        else
            false
        end
    end            

end

