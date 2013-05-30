#! /usr/bin/env ruby

require_relative 'BuggerDB'

class TaskTime	

	def initialize(id, start_time, stop_time, last_update, task_id)
		@id = id
		@start_time = start_time
		@stop_time = stop_time
		@last_update = last_update
		@task_id = task_id
		@database = BuggerDB.new
	end

    def start_time
    	@start_time
	end

	def stop_time
		@stop_time
	end

	def last_update
		@last_update
	end

	def task_id
		@task_id
	end

	def seconds_spent()
		#Rewrite this when not nite nite
		if(@stop_time.nil?)
			stop = Time.now.to_i
		else
			stop = DateTime.parse(stop).to_time.to_i
		end
		start = DateTime.parse(@start_time).to_time.to_i
		
		stop - start
	end

	def time_spent()
		TaskTime.pretty_print_time(seconds_spent)
	end


	def end()    
        sql = "update task_time set stop_time = DATETIME('now'), last_update=DateTime('now') where time_id=?"
        @database.execute(sql, @id)
	end

	def self.start(task_id)
		TaskTime.start_from(task_id, DateTime.new)
	end

	def self.start_from(task_id, start_time)
		sql = "insert into task_time values(null, DateTime(?), null, DateTime(?), ?)"
		sql_start_time = start_time.strftime("%Y-%d-%m %H:%M")
		last_update = DateTime.now
	    id = BuggerDB.new.insert(sql, [sql_start_time, last_update.strftime("%Y-%d-%m %H:%M"), task_id])
	    TaskTime.new(id, start_time, nil, last_update, task_id)
	end

	def self.last()
	    sql="select time_id, start_time, stop_time, last_update, task_id from task_time where stop_time is null"
	    result = BuggerDB.new.execute(sql, nil)
	    if (result.empty?)	    	
	        nil
	    else
	        row = result.first
	        TaskTime.new(row['time_id'], row['start_time'], row['stop_time'], row['last_update'], row['task_id'])
	    end
	end

	def self.pretty_print_time(seconds)		        
	    minutes = seconds / 60
	    hours = minutes / 60
	    extra_minutes = minutes - (hours * 60)        
	    format('%02d', hours) + "h:" + format('%02d', extra_minutes) + "m"
	end 
end