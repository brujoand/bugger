require 'date'
require 'launchy'

require_relative '../db/dbmodule'

class BugRapport
    include BuggerDB
    def generateRapportFor(date)        
        data = ''
        Work_times.new.for_date(date).each do |work_time|
            task = work_time.task
            data += Work_times.new.time_spent(work_time) + ' - ' + task.name + '</br>'
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





