#! /usr/bin/env ruby

require 'SQLite3'
require 'date'

require_relative '../config/config'

class BuggerDB
	def initialize()
		@db = SQLite3::Database.new(CONFIG['bugger_db'])
        @db.results_as_hash = true
	end

    def create_empty_db()
        sql_task = "create table 
            task (
                task_id INTEGER PRIMARY KEY,
                name VARCHAR,
                description VARCHAR
            );"
        sql_time_spent = "create table 
            task_time (
                time_id INTEGER PRIMARY KEY, 
                start_time DATETIME, 
                stop_time DATETIME,
                last_update DATETIME,
                task_id INTEGER, 
                FOREIGN KEY(task_id) REFERENCES task(task_id)
            );"        

        @db.execute(sql_task)
        @db.execute(sql_time_spent)
    end

    def initialize_empty_db()
        sql_task = "insert into task values(null, 'Installing bugger', 'This is how you do it')"
        @db.execute(sql_task)
        task_id = @db.last_insert_row_id
        
        sql_time_spent = "insert into task_time values(null, DateTime('now'), null, DateTime('now'), ?)"
        @db.execute(sql_time_spent, task_id)
    end

    def execute(sql, parameters)
        @db.execute(sql, parameters)
    end

    def insert(sql, parameters)
        @db.execute(sql, parameters)
        @db.last_insert_row_id
    end

end