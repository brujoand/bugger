#! /usr/bin/env ruby

require_relative 'BuggerDB'

class TaskTime	

	def initialize(id, start, stop, last_update, task_id)
		@id = id
		@start = start
		@stop = stop
		@last_update = last_update
		@task_id = task_id
		@db = BuggerDB.new
	end

    def start
    	@start
	end

	def stop
		if @stop.nil?
			now
		else
			@stop
		end
	end

	def last_update
		@last_update
	end

	def task_id
		@task_id
	end

	def seconds_spent()
		stop - start
	end

	def time_spent()
		TaskTime.pretty_print_time(seconds_spent)
	end

	def touch()
		sql = "update task_time set last_update=? where task_id=?"
		@db.execute(sql, [now, @task_id])
	end

	def end()    
		end_at(Time.now)
	end

	def end_at(time)
		sql = "update task_time set stop=?, last_update=? where time_id=?"
        @db.execute(sql, [time.to_i, now, @id])
	end

	def downtime?()
		time_since_update = now - @last_update
		if time_since_update > 1800 # This should be closely related to the bugger_intervall
			true
		else
			false
		end
	end

	def now()
		Time.now.to_i
	end

	#### Static methods ####	

	def self.start(task_id)
		TaskTime.start_from(task_id, Time.now)
	end

	def self.start_from(task_id, start)
		sql = "insert into task_time values(null, ?, null, ?, ?)"			
	    time_id = BuggerDB.new.insert(sql, [start.to_i, Time.now.to_i, task_id])
	    by_id(time_id)
	end

	def self.last()
	    sql = "select time_id from task_time where stop is null"
	    time_id = BuggerDB.new.execute(sql, nil).first['time_id']
	    by_id(time_id)
	end

	def self.pretty_print_time(seconds)		        
	    minutes = seconds / 60
	    hours = minutes / 60
	    extra_minutes = minutes - (hours * 60)        
	    format('%02d', hours) + "h:" + format('%02d', extra_minutes) + "m"
	end 

	def self.datetime_to_string(date)
		puts date.strftime("%Y-%m-%d %H:%M:%S")
        date.strftime("%Y-%m-%d %H:%M:%S")        
    end

    def self.for_date(date)
    	sql = "select * from task_time where Date(start, 'unixepoch') = Date(?, 'unixepoch') order by start"
    	result = BuggerDB.new.execute(sql, date.to_time.to_i)
    	tasks = Array.new
	    if (result.empty?)	    		    	
	        nil
	    else
	        result.each do |row|
				tasks.push(TaskTime.new(row['time_id'], row['start'], row['stop'], row['last_update'], row['task_id']))
			end
	    end
	    tasks
    end

    def self.by_id(time_id)
    	sql = "select * from task_time where time_id=?"
    	result = BuggerDB.new.execute(sql, time_id)
	    if (result.empty?)	    		    	
	        nil
	    else
	        row = result.first
	        TaskTime.new(row['time_id'], row['start'], row['stop'], row['last_update'], row['task_id'])
	    end
    end
end
