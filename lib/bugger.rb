#! /usr/bin/env ruby

require 'SQLite3'
require 'date'
require 'terminal-notifier'

require_relative '../db/task'
require_relative '../config/config'


class Bugger

    def bug(action)
        last_task = Task.last

        if (idle?)
            last_task.end if last_task != nil
            prompt_for_idle_time
        elsif (action == 'notify' && last_task != nil)
            show_notification(last_task)
        else            
            new_task = prompt_for_task(last_task) 
            if last_task.id != new_task
                last_task.end if last_task != nil
                new_task.start                            
            end
        end
    end

    def show_notification(active_task)
        callback = CONFIG['ruby_bin'] + " " + File.dirname(__FILE__) + "/../bugadm prompt" 
        title = "Time spent on task today: " + active_task.time_spent_today
        TerminalNotifier.notify(active_task.name, :title => title, :execute => callback)
    end

    def prompt_for_task(last_task)
        text = "Time spent on current task: #{last_task.time_spent_today}" 
        title = "Bugger - What are you working on?"
        task_name = %x(#{CONFIG['bugger_cocoa']} standard-inputbox --title "#{title}" --text "#{last_task.name}" --float --no-newline --no-cancel --informative-text #{text} | tail -n 1 )        
        Task.by_name(task_name)
    end

    def prompt_for_idle_time()
        idle_start=DateTime.now
        text = "You have been idle since: #{idle_start.strftime('%H:%M')}"
        title = "Bugger - What were you doing?"
        task_name = %x(#{CONFIG['bugger_cocoa']} standard-inputbox --title "#{title}" --float --no-newline --no-cancel --informative-text #{text} | tail -n 1 )        
        task = Task.by_name(task_name)
        task.start_from(idle_start)
        task
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

