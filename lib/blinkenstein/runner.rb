require 'celluloid'

module Blinkenstein 
  class Runner 
    include Celluloid

    attr_reader :blink
    attr_reader :monitors

    def initialize
      @monitors = []
      @blink    = Blink.new

      register(EveMonitor.new(blink))
    end

    def register(monitor)
      @monitors << monitor
      monitor.refresh
    end
  end
end
