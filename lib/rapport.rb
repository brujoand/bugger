#! /usr/bin/env ruby

require 'date'
require 'launchy'

require_relative '../db/task_time'

class BugRapport

    def initialize()
        
    end

    def secondsToTimeString(seconds)
        minutes = seconds / 60
        hours = minutes / 60
        extra_minutes = minutes - (hours * 60)
        format('%02d', hours) + "h:" + format('%02d', extra_minutes) + "m" 
    end

    def generateRapportFor(date)        
        data = ''
        TaskTime.for_date(date).each do |task_time|
            task = Task.by_id(task_time.task_id)            
            data += task_time.start_time + ' ' + task_time.stop_time + ' ' + task.name 
        end
        html = queryToHtml(data)
        html_file=writeToTmpFile(html)
        Launchy.open(html_file)
    end

    def queryToHtml(data)
        "<html>" +
        data + 
        "</html>"
    end

    def writeToTmpFile(data)
        filename = '/tmp/rapport.html'
        File.open(filename, 'w') { |file| file.write(data) }
        filename
    end

end





