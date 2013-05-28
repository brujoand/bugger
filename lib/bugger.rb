#! /usr/bin/env ruby

require 'SQLite3'
require 'date'
require 'terminal-notifier'
require_relative '../db/task'
require_relative '../config/config'


class Bugger

    def initialize()          
        @cocoa = CONFIG['bugger_cocoa']
    end

    def notify()
        idle_time=%x(echo $(($(ioreg -c IOHIDSystem | sed -e '/HIDIdleTime/!{ d' -e 't' -e '}' -e 's/.* = //g' -e 'q') / 1000000000))).to_i
        task = Task.last
        
        if (task.id == nil)
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
                callback = CONFIG['ruby_bin'] + " " + File.dirname(__FILE__) + "/../bugadm prompt" 
                TerminalNotifier.notify(task.name, :title => title, :execute => callback)
            end
        end
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

        new_task_name = %x(#{@cocoa} standard-inputbox --title "Bugger - What are you working on?" --text "#{task_name}" --float --no-newline --no-cancel --informative-text "Time spent on current task: #{time_spent}" | tail -n 1 )        

        new_task = Task.by_name(new_task_name)
        
        if new_task == nil
            task.end if task != nil
            new_task = Task.create(new_task_name,nil)
            new_task.start            
        elsif task.id != new_task
            task.end if task != nil
            task.start            
        end
    end

end

