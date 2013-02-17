require "spec_helper"
require "blinkenstein/monitors/eve_skill_queue_monitor"

module Blinkenstein
  describe SkillQueue do
    let(:skillQueue) { SkillQueue.new }

    before(:each) {
      skillQueue.stub(:query).and_return({characterID: "123", keyID: "123", vCode: "abc"})
    }

    describe "hours_left" do
      context "when more than one skill is qeueued" do
        it "calculates hours left by using the last queued skill" do
          VCR.use_cassette('skillqueue_many') do
            skillQueue.hours_left.should == 49
          end
        end
      end

      context "when exactly one skill is queued" do
        it "calculates hours left by using the last queued skill" do
          VCR.use_cassette('skillqueue_one') do
            skillQueue.hours_left.should == 44
          end
        end
      end

      context "when queue is empty" do
        it "returns 0" do
          VCR.use_cassette('skillqueue_empty') do
            skillQueue.hours_left.should == 0
          end
        end
      end

      context "when queue is paused" do
        it "returns 0" do
          VCR.use_cassette('skillqueue_paused') do
            skillQueue.hours_left.should == 0
          end
        end
      end

      context "when api is blocked" do
        it "returns -1h left" do
          VCR.use_cassette('skillqueue_blocked') do
            skillQueue.hours_left.should == -1 
          end
        end
      end
    end

    it "respects the cacheUntil setting" do
      SkillQueue.should_receive(:get).once.and_call_original

      VCR.use_cassette('skillqueue_one') do
        2.times { skillQueue.hours_left }
      end
    end

    it "fetches new data when the cache expires" do
      SkillQueue.should_receive(:get).twice.and_call_original
      
      VCR.use_cassette('skillqueue_one') do
        skillQueue.hours_left
      end

      skillQueue.instance_variable_set("@expire_time", (Time.now - 1))

      VCR.use_cassette('skillqueue_empty') do
        skillQueue.hours_left
      end
    end
  end

  describe "Eve" do
    describe "parse_date" do
      it "returns nil on unexpected input" do
        Eve.parse_date("HohOhO").should == nil
      end

      it "should parse eve formated dates" do
        Eve.parse_date("1976-11-04 09:17:23").should == DateTime.new(1976, 11, 4, 9, 17, 23) 
      end
    end
  end


  describe EveSkillQueueMonitor do
    let(:monitor) { EveSkillQueueMonitor.new }

    describe "refresh" do
      it "goes into error mode if queue left is < 0" do
        monitor.stub(:hours_left).and_return(-1)
        monitor.should_receive(:error)
        monitor.refresh
      end

      it "is cool if the skill queue is longer than 24h" do
        monitor.stub(:hours_left).and_return(25)
        monitor.should_receive(:cool)
        monitor.refresh
      end

      it "is nervous if the skill queue is between 9h and 24h long" do
        monitor.stub(:hours_left).and_return(9)
        monitor.should_receive(:nervous)
        monitor.refresh
      end

      it "is panicing if the skill queue is below 8h long" do
        monitor.stub(:hours_left).and_return(0)
        monitor.should_receive(:panic)
        monitor.refresh
      end
    end
  end
end
