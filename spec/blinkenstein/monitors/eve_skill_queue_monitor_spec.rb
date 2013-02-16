require "spec_helper"
require "blinkenstein/monitors/eve_skill_queue_monitor"

module Blinkenstein
  describe SkillQueue do
    let(:skillQueue) { SkillQueue.new }

    describe "::update" do
      it "calculated the hours left" do
        VCR.use_cassette('skillqueue_full') do
          skillQueue.stub(:query).and_return({characterID: "123", keyID: "123", vCode: "abc"})
          skillQueue.hours_left.should == 44
        end
      end
    end
  end


  describe EveSkillQueueMonitor do
    let(:monitor) { EveSkillQueueMonitor.new }

    describe "::refresh" do
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
        monitor.stub(:hours_left).and_return(-2)
        monitor.should_receive(:panic)
        monitor.refresh
      end
    end
  end
end
