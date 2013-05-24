#! /usr/bin/env ruby

require 'SQLite3'
require 'date'
require 'active_support/core_ext'

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
        @db.execute(sql, date).each do |row|
            seconds = row[2].to_i - row[1].to_i
            puts secondsToTimeString(seconds) + " - " + row[0]
        end
    end

    def prettyPrint(date)

    end

end



db_path = ARGV[0]
bugrapport=BugRapport.new(db_path)

if (ARGV.length == 1)
    bugrapport.generateRapportFor(DateTime.new.to_date)
elsif (ARGV.length == 2)
    date = ARGV[1]
    bugrapport.generateRapportFor(date)
end





