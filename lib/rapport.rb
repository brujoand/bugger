#! /usr/bin/env ruby

require 'date'
require 'launchy'

require_relative '../db/task_time'

class BugRapport
    def generateRapportFor(date)        
        data = ''
        TaskTime.for_date(date).each do |task_time|
            task = Task.by_id(task_time.task_id)            
            data += task_time.time_spent + ' - ' + task.name + '</br>'
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





