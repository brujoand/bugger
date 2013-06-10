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

    def self.by_name(name)		
		sql = "select * from task where name=?"
		result = BuggerDB.new.execute(sql, name)
		if result.empty?
			Task.create(name, nil)
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
		Task.new(task_id, name, description)
	end

end
