#! /usr/bin/env ruby

require 'date'
require 'terminal-notifier'

require_relative '../db/task'
require_relative '../db/task_time'
require_relative '../config/config'


class Bugger

    def bug(action)
        last_task_time = TaskTime.last

        if (idle?)
            last_task_time.end 
            prompt_for_idle_time
        elsif (action == 'notify')
            show_notification(last_task_time)
        else            
            task = prompt_for_task(last_task_time) 
            if last_task_time.task_id != task.id
                last_task_time.end
                TaskTime.start(task.id)                   
            end
        end
    end

    def show_notification(active_task_time)
        callback = CONFIG['ruby_bin'] + " " + File.dirname(__FILE__) + "/../bugadm prompt" 
        title = "Time spent on task today: " + active_task_time.time_spent 
        active_task = Task.by_id(active_task_time.task_id)
        TerminalNotifier.notify(active_task.name, :title => title, :execute => callback)
    end

    def prompt_for_task(last_task_time)
        text = "Time spent on current task: #{last_task_time.time_spent}" 
        title = "Bugger - What are you working on?"
        task = Task.by_id(last_task_time.task_id)
        task_name = %x(#{CONFIG['bugger_cocoa']} standard-inputbox --title "#{title}" --text "#{task.name}" --float --no-newline --no-cancel --informative-text #{text} | tail -n 1 )        
        Task.by_name(task_name)
    end

    def prompt_for_idle_time()
        idle_start=DateTime.now
        text = "You have been idle since: #{idle_start.strftime('%H:%M')}"
        title = "Bugger - What were you doing?"
        task_name = %x(#{CONFIG['bugger_cocoa']} standard-inputbox --title "#{title}" --float --no-newline --no-cancel --informative-text #{text} | tail -n 1 )        
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

