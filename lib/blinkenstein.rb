require "blinkenstein/version"
require "blinkenstein/runner"
require "blinkenstein/blink"

module Blinkenstein
  class SupervisionGroup < Celluloid::SupervisionGroup
    supervise Runner
  end
end

require "blinkenstein/monitors/eve"


