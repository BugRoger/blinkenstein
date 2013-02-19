require 'celluloid'
require 'blink1'

module Blinkenstein 
  class Runner 
    include Celluloid
    include Logging

    def initialize
      refresh_all

      every(15) do
        refresh_all
      end
    end

    def refresh_all
      debug "Refreshing all monitors"
      Monitor.repository.each(&:refresh)
    end

    def finalize
      info "Shutting down. Turning off the lights..."
      Blink1.open do |blink1|
        blink1.off
      end
    end
  end
end
