require_relative 'BuggerDB'

class TaskTime	

    attr_reader :id, :start, :last_update, :task_id

	def initialize(id, start, stop, last_update, task_id)
		@id = id
		@start = start
		@stop = stop
		@last_update = last_update
		@task_id = task_id
		@db = BuggerDB.new
	end

	def stop
		if @stop.nil?
			now
		else
			@stop
		end
	end

	def seconds_spent()
		stop - start
	end

	def time_spent()
		TaskTime.pretty_print_time(seconds_spent)
	end

	def touch()
		sql = "update task_time set last_update=? where time_id=?"
		@db.execute(sql, [now, @id])
	end

	def end(time=now)
		sql = "update task_time set stop=?, last_update=? where time_id=?"
        @db.execute(sql, [time, time, @id])
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
		now = Time.now.to_i
	end

	#### Static methods ####	

	def self.start(task_id, start=now)
		sql = "insert into task_time values(null, ?, null, ?, ?)"			
	    time_id = BuggerDB.new.insert(sql, [start.to_i, start.to_i, task_id])
	    by_id(time_id)
	end

	def self.last()
	    sql = "select max(time_id) as time_id from task_time"
	    time_id = BuggerDB.new.execute(sql, nil).first['time_id']
	    by_id(time_id)
	end

	def self.pretty_print_time(seconds)		        
	    minutes = seconds / 60
	    hours = minutes / 60
	    extra_minutes = minutes - (hours * 60)        
	    format('%02d', hours) + "h:" + format('%02d', extra_minutes) + "m"
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
