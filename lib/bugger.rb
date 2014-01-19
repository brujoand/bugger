require 'date'
require 'terminal-notifier'

require_relative '../db/dbmodule'
require_relative '../views/dialog'
require_relative '../config/bugdata'


class Bugger
    include BuggerDB

    @work_times
    @tasks

    def bug(action)
        @work_times = Work_times.new
        @tasks = Tasks.new      
        work_time = @work_times.last        

        if are_we_idle?
            puts 'We have been idle'
            @work_times.end(work_time)
            register_idle_time
        end

        if have_we_had_downtime?
            puts 'We have been down'            
            task = prompt_for_task(work_time)
            work_time.end(work_time.last_update)
            @work_times.create(task)
        elsif action == 'notify'
            show_notification(work_time)
            @work_times.update(work_time)
        else            
            task = prompt_for_task(work_time) 
            if work_time.task.id != task.id
                @work_times.end(work_time)
                @work_times.create(task)
            else
                @work_times.update(work_time)
            end
        end
    end

    def show_notification(work_time)
        callback = BugData.config.ruby_bin + " " + File.dirname(__FILE__) + "/../bugadm prompt" 
        title = "Time spent on task today: " + @work_times.time_spent(work_time)
        task = work_time.task
        TerminalNotifier.notify(task.name, :title => title, :execute => callback)        
    end

    def prompt_for_task(work_time)
        
        text = "Time spent on current task: #{@work_times.time_spent(work_time)}" 
        title = "Bugger - What are you working on?"
        last_task = work_time.task
        task_name = BugDialog.prompt_for_task(title, text, last_task.name)
        @tasks.by_name(task_name)
    end

    def are_we_idle?()
        idle_time = %x[ #{'#{BugData.config.base_path}./bin/idler'} ]
        if idle_time.to_i > BugData.config.bugfreq
            true
        else
            false
        end
    end

    def have_we_had_downtime?()
        # Ask db for last task update / not idle or downtime
        if 1 > 10
            true
        else
            false
        end
    end

    def register_idle_time() ####### fix, not working
        idle_start=Time.now
        text = "You have been idle since: #{idle_start.strftime('%H:%M')}"
        title = "Bugger - What were you doing?"
        task_name = BugDialog.prompt_for_task(title, text, '')
        task = task.by_name(task_name)
        workTime.create(task.id) ## ned to pass starttime for idle
    end            

end

