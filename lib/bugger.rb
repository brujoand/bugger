#! /usr/bin/env ruby

require 'SQLite3'
require 'date'
require 'terminal-notifier'

require_relative 'database'

class Bugger

    def initialize(db_path, cocoa)
        @database = Database.new(db_path)        
        @cocoa = cocoa
    end

    def notify()
        idle_time=%x(echo $(($(ioreg -c IOHIDSystem | sed -e '/HIDIdleTime/!{ d' -e 't' -e '}' -e 's/.* = //g' -e 'q') / 1000000000))).to_i
        task_id = @database.get_last_task

        if (task_id == nil)
            prompt
        else
            title = "Time spent on task: " + @database.time_spent_by(task_id)
            task_name = @database.get_task_name(task_id)
            
            # TODO match on id instead
            if(idle_time > 300 and task_name != 'idle')
                @database.end_current(task_id)
                @database.register_new_task('idle')
            else                        
                callback = File.dirname(__FILE__) + "/../bugadm prompt" 
                TerminalNotifier.notify(task_name, :title => title, :execute => callback)
            end
        end
    end

    def prompt()
        task_id = @database.get_last_task
        if(task_id == nil)
            time_spent='00h:00m'
            task_name=''
        else            
            time_spent = @database.time_spent_by(task_id)
            task_name = @database.get_task_name(task_id)
        end
        new_task = %x(#{@cocoa} standard-inputbox --title "Bugger - What are you working on?" --text "#{task_name}" --float --no-newline --no-cancel --informative-text "Time spent on current task: #{time_spent}" | tail -n 1 )        

        if (task_name != new_task)
            @database.end_current(task_id)
            @database.register_new_task(new_task)
        end
    end

end

