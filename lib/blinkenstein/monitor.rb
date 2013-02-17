module Blinkenstein
  module Monitor
    extend Logging
    
    def self.repository
      @repository ||= []
    end

    def self.included(klass)
      logger.info "Registering monitor #{klass}"
      repository << klass.new
    end
  end
end