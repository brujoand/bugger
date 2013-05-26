#! /usr/bin/env ruby

require 'SQLite3'
require 'date'
require 'launchy'

class BugRapport

    def initialize(db_path)
        @db = SQLite3::Database.new(db_path)
    end

    def secondsToTimeString(seconds)
        minutes = seconds / 60
        hours = minutes / 60
        extra_minutes = minutes - (hours * 60)
        format('%02d', hours) + "h:" + format('%02d', extra_minutes) + "m" 
    end

    def generateRapportFor(date)
        sql = "select name, strftime('%s',time_start), strftime('%s',time_stop) from time_spent natural join task where DATE(time_start) = DATE(?) and time_stop is not null"
        data=''
        @db.execute(sql, date).each do |row|
            seconds = row[2].to_i - row[1].to_i
            data += secondsToTimeString(seconds) + " - " + row[0] 
        end    
        html = queryToHtml(data)
        html_file=writeToTmpFile(html)
        Launchy.open(html_file)
    end

    def queryToHtml(date)
        date
    end

    def writeToTmpFile(data)
        filename = '/tmp/rapport.html'
        File.open(filename, 'w') { |file| file.write(data) }
        filename
    end

end



db_path = ARGV[0]
bugrapport=BugRapport.new(db_path)

if (ARGV.length == 1)
    bugrapport.generateRapportFor(DateTime.now.to_date.to_s)
elsif (ARGV.length == 2)
    date = ARGV[1]
    bugrapport.generateRapportFor(date)
end





