#! /usr/bin/env ruby

require 'SQLite3'
require 'date'
require 'terminal-notifier'

class Bugger

    def initialize(db_path, cocoa)
        @db = SQLite3::Database.new(db_path)
        @cocoa = cocoa
    end

    def get_last_task()
        sql="select time_id from time where timestop is null"
        result = @db.execute(sql)
        if (result.empty?)
            nil
        else
            result[0][0]            
        end
    end

    def get_task_name(id)
        sql="select name from task where task_id = ?"
        @db.execute(sql, id)[0][0]
    end

    def time_spent_by(id)
        sql = "select strftime('%s',timeStart), strftime('%s','now') from time where task_id=?"
        row = @db.execute(sql, id)[0]
        timestart = row.to_i
        now = row.to_i        
        seconds = now - timestart
        minutes = seconds / 60
        hours = minutes / 60
        extra_minutes = minutes - (hours * 60)        
        format('%02d', hours) + "h:" + format('%02d', extra_minutes) + "m"
    end

    def notify()
        idle_time=%x(echo $(($(ioreg -c IOHIDSystem | sed -e '/HIDIdleTime/!{ d' -e 't' -e '}' -e 's/.* = //g' -e 'q') / 1000000000))).to_i
        task_id = get_last_task
        if (task_id == nil)
            prompt
            exit
        else
            title = "Time spent on task: " + time_spent_by(task_id)
            task_name = get_task_name(task_id)
            
            # TODO match on id instead
            if(idle_time > 900 and task_name != 'idle')
                end_current(task_id)
                register_new_task('idle')
            else                        
                callback = File.dirname(__FILE__) + "/../bugadm prompt" 
                TerminalNotifier.notify(task_name, :title => title, :execute => callback)
            end
        end
    end

    def end_current(id)
        if (!id == nil)
            sql = "update time set timeStop = DATETIME('now') where task_id=?"
            @db.execute(sql, id)
        end
    end

    def register_new_task(task_name)
        puts "registering new task: #{task_name}"
        sql_task = "insert into task values(null, ?, null)"
        @db.execute(sql_task, task_name)
        sql_task_id = "select task_id from task where name=?"
        task_id = @db.execute(sql_task,task_name)[0]
        sql_time = "insert into time values(null, DATETIME('now'), null, null, ?)"
        @db.execute(sql_time, task_id)
    end

    def prompt()
        task_id = get_last_task
        if(task_id == nil)
            time_spent='00h:00m'
            task_name=''
        else            
            time_spent = time_spent_by(task_id)
            task_name = get_task_name(task_id)
        end
        new_task = %x(#{@cocoa} standard-inputbox --title "Bugger - What are you working on?" --text "#{task_name}" --float --no-newline --no-cancel --informative-text "Time spent on current task: #{time_spent}" | tail -n 1 )
        if (task_name != new_task)
            #TODO check for null
            end_current(task_id)
            register_new_task(new_task)
        end
    end

end

if (ARGV.length < 2)
    puts "usage be angry!"
    exit 
end

db_path = ARGV[0]
cocoa = ARGV[1]
bugger = Bugger.new(db_path, cocoa)

if (ARGV.length == 2)
    bugger.notify
elsif (ARGV.length == 3)
    bugger.prompt
end
