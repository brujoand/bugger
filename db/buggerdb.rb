require 'SQLite3'
require 'date'
require_relative '../config/bugdata'

class BuggerDB
    def initialize(db_path = BugData.config.db_path)
        @db = SQLite3::Database.new(db_path)
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
                start INTEGER, 
                stop INTEGER,
                last_update INTEGER,
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
        
        timestamp = Time.now.to_i
        sql_time_spent = "insert into task_time values(null, ?, null, ?, ?)"
        @db.execute(sql_time_spent, [timestamp, timestamp, task_id])
    end

    def execute(sql, parameters)
        @db.execute(sql, parameters)
    end

    def insert(sql, parameters)
        @db.execute(sql, parameters)
        @db.last_insert_row_id
    end

    def drop_db()
        @db.execute('drop table if exists task_time')
        @db.execute('drop table if exists task')
    end

end