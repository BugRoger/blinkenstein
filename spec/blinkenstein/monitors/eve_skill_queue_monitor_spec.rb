require "spec_helper"
require "blinkenstein"

module Blinkenstein
  describe EveSkillQueueMonitor do
    let(:monitor) { EveSkillQueueMonitor.new }

    describe "refresh" do
      it "goes into error mode if queue left is < 0" do
        monitor.stub(:hours_left).and_return(-1)
        monitor.should_receive(:failure)
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

    describe ".hours_left" do
      it "is showing a failure if something is wrong while calling the API" do
        Eve::SkillQueue.any_instance.stub(:hours_left).and_raise("whatever")
        monitor.should_receive(:failure)
        monitor.hours_left
      end
    end
  end
end
