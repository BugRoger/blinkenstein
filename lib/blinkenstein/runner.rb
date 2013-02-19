require 'celluloid'
require 'blink1'

module Blinkenstein 
  class Runner 
    include Celluloid
    include Logging

    def initialize
      register_all
      refresh_all

      every(15) do
        refresh_all
      end
    end

    def register_all
      @monitors = Monitor.monitors.map do |monitor|
        info "Registering montitor: #{monitor}"
        monitor.new
      end
    end

    def refresh_all
      debug "Refreshing all monitors"
      @monitors.each(&:refresh)
    end

    def finalize
      info "Shutting down. Turning off the lights..."
      Blink1.open do |blink1|
        blink1.off
      end
    end
  end
end
