#! /usr/bin/env ruby

require 'SQLite3'
require 'date'

class DBBugger
	def initialize(db_path)
		@db = SQLite3::Database.new(db_path)
	end

    def get_last_task()
	    sql="select task_id from time where timestop is null"
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

    def end_current(id)
	    if (id != nil)
	        sql = "update time set timeStop = DATETIME('now') where task_id=?"
	        @db.execute(sql, id)
	    end
	end

	def register_new_task(task_name)
        sql_task_id = "select task_id from task where name=?"
        task_id_row = @db.execute(sql_task_id,task_name)
        if (task_id_row.empty?)            
            puts "registering new task: #{task_name}"
            sql_task = "insert into task values(null, ?, null)"
            @db.execute(sql_task, task_name)

            sql_task_id = "select task_id from task where name=?"
            task_id = @db.execute(sql_task_id,task_name)[0]
        else
            puts "Found existing id for task: #{task_name}"
            task_id=task_id_row[0]
        end
        
        sql_time = "insert into time values(null, DATETIME('now'), null, null, ?)"
        @db.execute(sql_time, task_id)
    end

    def time_spent_by(id)
        puts "Checking time spent for task_id: #{id}"
        sql = "select strftime('%s',timeStart), strftime('%s','now') from time where task_id=?"
        row = @db.execute(sql, id)[0]
        timestart = row[0].to_i
        now = row[1].to_i        
        seconds = now - timestart
        minutes = seconds / 60
        hours = minutes / 60
        extra_minutes = minutes - (hours * 60)        
        format('%02d', hours) + "h:" + format('%02d', extra_minutes) + "m"
    end
end