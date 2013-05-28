#! /usr/bin/env ruby

require 'SQLite3'
require 'date'
require 'terminal-notifier'

require_relative '../db/task'
require_relative '../config/config'


class Bugger
    def update(task)
        new_task_name = %x(#{@cocoa} standard-inputbox --title "Bugger - What were you working on?" --float --no-newline --no-cancel --informative-text "Time spent away: #{time_spent}" | tail -n 1 )
        new_task = Task.by_name(new_task_name)
        if new_task == nil
            new_task = Task.create(new_task_name,nil)
        end
        new_task.update
    end

    def show_notification(task)
        callback = CONFIG['ruby_bin'] + " " + File.dirname(__FILE__) + "/../bugadm prompt" 
        title = "Time spent on task: " + task.time_spent_today
        TerminalNotifier.notify(task.name, :title => title, :execute => callback)
    end

    def notify()
        idle_time=%x(echo $(($(ioreg -c IOHIDSystem | sed -e '/HIDIdleTime/!{ d' -e 't' -e '}' -e 's/.* = //g' -e 'q') / 1000000000))).to_i
        task = Task.last
        
        if (task.id == nil)
            prompt
        elsif (task.name == 'idle')
            # Change the task
            # update task
            prompt
        else            
            title = "Time spent on task: " + task.time_spent_today
            task_name = task.name
            
            # TODO match on id instead
            if(idle_time > 300 and task.name != 'idle')
                task.end
                new_task = Task.create('idle', nil)
                new_task.start
            else           
                show_notification(task)
            end
        end
    end

    def prompt_for_task(old_task)
        text = "Time spent on current task: #{old_task.time_spent_today}"
        title = "Bugger - What are you working on?"
        task_name = %x(#{CONFIG['bugger_cocoa']} standard-inputbox --title "#{title}" --text "#{old_task.name}" --float --no-newline --no-cancel --informative-text #{text} | tail -n 1 )        
        task = Task.by_name(task_name)
        if (task == nil)
            task = Task.create(task_name, nil)
        end
        task
    end

    def prompt()
        task = Task.last
        if(task == nil)
            time_spent='00h:00m'
            task_name=''
        else            
            time_spent = task.time_spent_today
            task_name = task.name
        end

        new_task = prompt_for_task(task)        
        
        if task.id != new_task
            task.end if task != nil
            new_task.start            
        end
    end

end

