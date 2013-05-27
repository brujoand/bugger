#! /usr/bin/env ruby

require_relative 'BuggerDB'

class Task
	def initialize(id, name, description)
		@id = id
		@name = name
		@description = description
		@database = BuggerDB.new	
	end

	def id
		@id 
	end

	def name
		@name
	end

	def description
		@description
	end

	def start()
		sql_time = "insert into time_spent values(null, DATETIME('now'), null, null, ?)"
        @database.execute(sql_time, id)
    end

	def end()    
        sql = "update time_spent set time_stop = DATETIME('now') where task_id=?"
        @database.execute(sql, id)
	end

	def time_spent_today()
		sql = "select strftime('%s',time_start), strftime('%s','now') from time_spent where task_id=? and Date(time_start)=Date('now')"
		seconds=0
        @database.execute(sql, id).each { |row|
            seconds += row[1].to_i - row[0].to_i
        }        
            
        minutes = seconds / 60
        hours = minutes / 60
        extra_minutes = minutes - (hours * 60)        
        format('%02d', hours) + "h:" + format('%02d', extra_minutes) + "m"
    end    

    def self.by_name(name)		
		sql = "select * from task where name=?"
		result = BuggerDB.new.execute(sql, name)
		if result.empty?
			nil
		else
			row = result.first
			Task.new(row['task_id'], row['name'], row['description'])
		end
	end    

	def self.by_id(id)
		sql = "select * from task where task_id=?"
		result = BuggerDB.new.execute(sql, id)
		if result.empty?
			nil
		else
			row = result.first
			Task.new(row['task_id'], row['name'], row['description'])
		end
	end

	def self.create(name, description)
		sql = "insert into task values(null, ?, ?)"
		task_id = BuggerDB.new.insert(sql, [name, description])
		by_id(task_id)
	end

	def self.last()
	    sql="select task_id, name, description from time_spent natural join task where time_stop is null"
	    result = BuggerDB.new.execute(sql, nil)
	    if (result.empty?)	    	
	        nil
	    else
            row = result.first          
	        Task.new(row['task_id'], row['name'], row['description'])
	    end
    end

end
