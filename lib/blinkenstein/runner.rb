require 'celluloid'

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
      logger.debug "Refreshing all monitors"
      Monitor.repository.each(&:refresh)
    end
  end
end
