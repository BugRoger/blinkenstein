require 'celluloid'

module Blinkenstein 
  class Runner 
    include Celluloid

    attr_reader :monitors

    def initialize
      @monitors = []

      register(EveSkillQueueMonitor.new)

      every(15) do
        @monitors.each(&:refresh)
      end
    end

    def register(monitor)
      @monitors << monitor
      monitor.refresh
    end
  end
end
