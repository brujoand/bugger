require 'sqlite3'
require_relative '../config/bugdata'
require_relative '../db/dbmodule'

module BuggerDB

  class DatabaseAccess

    def initialize(db_path)
      @db = SQLite3::Database.new(db_path)
      @db.results_as_hash = true
    end

    def prepare_schema
      @db.execute(task_sql)
      @db.execute(time_spent_sql)
      @db.execute(first_task_sql)
      @db.execute(first_work_time_sql)
    end

    def task_sql
      "create table 
        task (
          task_id INTEGER PRIMARY KEY,
          name VARCHAR NOT NULL,
          description VARCHAR
        );"
    end

    def time_spent_sql
      "create table 
        work_time (
          work_time_id INTEGER PRIMARY KEY, 
          start INTEGER, 
          stop INTEGER,
          last_update INTEGER,
          task_id INTEGER, 
          FOREIGN KEY(task_id) REFERENCES task(task_id)
        );" 
    end

    def first_task_sql
      "insert into task(name, description) values('idle', 'this is the first task');"
    end

    def first_work_time_sql
      "insert into work_time values(null, 0, null, 0, 1)"
    end

    def execute(sql, parameters)
      @db.execute(sql, parameters)
    end

    def insert(sql, parameters)
      execute(sql, parameters)
      @db.last_insert_row_id
    end

  end

  class Task
    attr_reader :id
    attr_accessor :name, :description

    def initialize(id, name, description)
      @id = id
      @name = name
      @description = description
    end

    def to_s
      "Task(#{@id}, #{@name}, #{@description})"
    end

  end

  class Tasks

    def initialize(db_path = BugData.config.db_path)
      @db = DatabaseAccess.new(db_path)
    end

    def from_row(row)
      Task.new(row["task_id"], row["name"], row["description"])
    end

    def by_name(name)
      rows = @db.execute("select * from task where name=?", name)
      if rows.empty?
        create(name)
      else
        from_row(rows.first)
      end
    end

    def by_id(id)
      rows = @db.execute("select * from task where task_id=?", id)
      if rows.empty?
        nil
      else
        from_row(rows.first)
      end
    end

    def create(name, description=nil)
      id = @db.insert("insert into task(name, description) values(?, ?)", [name, description])
      Task.new(id, name, description)
    end

    def save(task)
      if task.id.nil?
        create(task.name, task.description)
      else
        @db.execute("update task set name = ?, description = ? where task_id = ?",
                          [task.name, task.description, task.id])
        task
      end
    end

    def all
      rows = @db.execute("select * from task")
      rows.map do | row |
        from_row(row)
      end
    end
  end

  class Work_time
    attr_reader :id, :stop
    attr_accessor :start, :last_update, :task

      def initialize(id, start, stop, last_update, task)
        @id = id
        @start = start
        @stop = stop
        @last_update = last_update
        @task = task
      end

      def seconds_spent()
        if(nil == stop)
          Time.now.to_i - start
        else
          stop - start
        end
      end

      def to_s
        "Task_time(#{@id}, #{@task_id}, #{@name}, #{@start}, #{@stop}, #{@last_update})"
      end
  end

  class Work_times
    
    def initialize(db_path = BugData.config.db_path)
      @db = DatabaseAccess.new(db_path)
    end

    def now()
      now = Time.now.to_i
    end

    def time_spent(work_time)
      pretty_print_time(work_time.seconds_spent)
    end

    def pretty_print_time(seconds)
      minutes = seconds / 60
      hours = minutes / 60
      extra_minutes = minutes - (hours * 60)        
      format('%02d', hours) + "h:" + format('%02d', extra_minutes) + "m"
    end

    def update(work_time)
        @db.execute("update work_time set last_update = ? where work_time_id = ?", [now, work_time.task.id])
    end

    def end(work_time, time=now)
      sql = "update work_time set stop=?, last_update=? where work_time_id=?"
      @db.execute(sql, [time, time, work_time.id])
    end

    def create(task)
      start_time = now
      id = @db.insert("insert into work_time values(null, ?, null, ?, ?)", [start_time, start_time, task.id])
      Work_time.new(id, start_time, nil, start_time, task )
    end

    def last()
      sql = "select max(work_time_id) as work_time_id from work_time"
      work_time_id = @db.execute(sql, nil).first['work_time_id']
      by_id(work_time_id)
    end

    def by_id(work_time_id)
      sql = "select * from work_time where work_time_id=?"
      result = @db.execute(sql, work_time_id)
      if (result.empty?)                
          nil
      else
          row = result.first
          Work_time.new(row['work_time_id'], row['start'], row['stop'], row['last_update'], Tasks.new.by_id(row['task_id']))
      end
    end

    def for_date(date)
      sql = "select * from work_time where Date(start, 'unixepoch') = Date(?, 'unixepoch') order by start"
      result = @db.execute(sql, date.to_time.to_i)
      tasks = Array.new
      if (result.empty?)                
          nil
      else
          result.each do |row|
            tasks.push(Work_time.new(row['time_id'], row['start'], row['stop'], row['last_update'], Tasks.new.by_id(row['task_id'])))
          end
      end

      tasks
    end
  end
end
