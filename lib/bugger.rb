#! /usr/bin/env ruby

require 'SQLite3'
require 'date'
require 'terminal-notifier'

require_relative 'database'

class Bugger

    ## Om det er mer en 20 minutter siden update av siste innslag, sett tid som sleep
    ## konsekvent bruk av snake
    ## bibliotek shellcommands
    ## ikke () i if
    ## task_id.nil?
    ## en parametr, ingen ()
    ## dbbugger nytt navn
    ## DTO'er
    ## ikke get i metodenavn

    def initialize(db_path, cocoa)
        @database = DBBugger.new(db_path)        
        @cocoa = cocoa
    end

    def notify_about_current_task()
        idle_time=%x(echo $(($(ioreg -c IOHIDSystem | sed -e '/HIDIdleTime/!{ d' -e 't' -e '}' -e 's/.* = //g' -e 'q') / 1000000000))).to_i
        task_id = @database.get_last_task

        if (task_id == nil)
            prompt_for_current_task
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

    def prompt_for_current_task()
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


db_path = ARGV[0]
cocoa = ARGV[1]
bugger = Bugger.new(db_path, cocoa)

if (ARGV.length == 2)
    bugger.notify_about_current_task
elsif (ARGV.length == 3)
    bugger.prompt_for_current_task
end
