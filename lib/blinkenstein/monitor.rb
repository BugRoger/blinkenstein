module Blinkenstein
  module Monitor
    class << self
      attr_accessor :monitors
    end

    @monitors = []

    def self.included(klass)
      @monitors << klass
    end
  end
end
