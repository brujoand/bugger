#! /usr/bin/env ruby

module BugData
    class << self
        attr_accessor :config
    end

    def self.configure
        self.config ||= Config.new
        yield(config)
    end

    class Config
        attr_accessor :base_path, :db_path, :bugfreq, :launchd_plist, :ruby_bin, :env
        
        def initialize
            @base_path = File.expand_path('..', File.dirname(__FILE__ ))
        	@ruby_bin = RbConfig.ruby
        	@db_path = @base_path + '/db/bug.db'
        	@bugfreq = 900
        	@launchd_plist = '/Users/anders/Library/LaunchAgents/no.brujordet.bugger.plist'
            @env = "prod"
        end
    end

end