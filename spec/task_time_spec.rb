require 'spec_helper'
require_relative '../config/bugdata'


describe TaskTime do	

	before :all do        
        BugData.configure do |config|
            config.db_path = ':memory'
            config.env="test"
        end
		@db = BuggerDB.new()
		@db.create_empty_db
		@db.initialize_empty_db
	end

	before :each do
		@task_time = TaskTime.last
	end

	describe "#new" do
	    it "takes five parameters and returns a TaskTime object" do
	        @task_time.should be_an_instance_of TaskTime
	    end
	end

	describe "#end" do
		it "ends a task_time and sets update to endtime" do
			@task_time.end
			@task_time.stop.should == @task_time.last_update
		end
	end

	after :all do
		@db.drop_db
	end
end