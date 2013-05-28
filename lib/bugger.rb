#! /usr/bin/env ruby

require 'SQLite3'
require 'date'
require 'terminal-notifier'

require_relative '../db/task'
require_relative '../config/config'


class Bugger

    def bug(action)
        task = Task.last

        if (idle?)
            task.end if task != nil
            prompt_for_idle_time
        elsif (action == 'notify' && task != nil)
            show_notification(task)
        else            
            new_task = prompt_for_task(task) 
            if task.id != new_task
                task.end if task != nil
                new_task.start                            
            end
        end
    end

    def show_notification(task)
        callback = CONFIG['ruby_bin'] + " " + File.dirname(__FILE__) + "/../bugadm prompt" 
        title = "Time spent on task: " + task.time_spent_today
        TerminalNotifier.notify(task.name, :title => title, :execute => callback)
    end

    def prompt_for_task(old_task)
        text = "Time spent on current task: #{old_task.time_spent_today}"
        title = "Bugger - What are you working on?"
        task_name = %x(#{CONFIG['bugger_cocoa']} standard-inputbox --title "#{title}" --text "#{old_task.name}" --float --no-newline --no-cancel --informative-text #{text} | tail -n 1 )        
        Task.by_name(task_name)
    end

    def prompt_for_idle_time()
        idle_start=DateTime.now
        text = "You have been idle since: #{idle_start}"
        title = "Bugger - You left us!?"
        task_name = %x(#{CONFIG['bugger_cocoa']} standard-inputbox --title "#{title}" --float --no-newline --no-cancel --informative-text #{text} | tail -n 1 )        
        task = Task.by_name(task_name)
        task.update_times(idle_start, DateTime.now)
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

