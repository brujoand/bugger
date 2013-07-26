require 'spec_helper'


describe TaskTime do    

    before :all do        
        BugData.configure do |config|
            config.db_path = '/tmp/bugger_test.db'
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

        it "should get it self by it's own id" do
            TaskTime.by_id(@task_time.id).id.should == @task_time.id
        end
    end

    describe "#end" do
        it "ends a task_time and sets update to endtime" do
            sleep(2)
            @task_time.end
            @task_time = TaskTime.last
            @task_time.stop.should == @task_time.last_update            
        end

        it "ends a task_time at a different time than start" do
            sleep(2)
            @task_time.end
            @task_time = TaskTime.last
            @task_time.stop.should_not == @task_time.start
        end
    end

    describe "#downtime" do
        it "checks if we have been sleeping, based on last_update" do
            @task_time.end
            task = Task.by_id('testing downtime')
            start_time = Time.now.to_i - 36000
            TaskTime.start(task, start_time).downtime?.should == true
        end
    end    

    after :all do
        @db.drop_db
    end
end