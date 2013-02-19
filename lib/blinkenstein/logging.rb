require "logger"

module Blinkenstein
  class << self
    attr_accessor :logger
  end

  @logger       = Logger.new(STDOUT)
  @logger.level = ENV["DEBUG"] ? Logger::DEBUG : Logger::INFO

  module Logging
    def debug(*args)
      Blinkenstein.logger.debug(*args) if Blinkenstein.logger
    end

    def info(*args)
      Blinkenstein.logger.info(*args) if Blinkenstein.logger
    end

    def warn(*args)
      Blinkenstein.logger.warn(*args) if Blinkenstein.logger
    end

    def error(*args)
      Blinkenstein.logger.error(*args) if Blinkenstein.logger
    end

    def fatal(*args)
      Blinkenstein.logger.error(*args) if Blinkenstein.logger
    end
  end
end
