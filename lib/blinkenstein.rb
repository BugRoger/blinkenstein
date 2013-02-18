require "celluloid"
require "blink1-patterns"

require "blinkenstein/version"
require "blinkenstein/logging"
require "blinkenstein/monitor"
require "blinkenstein/runner"

module Blinkenstein
  class SupervisionGroup < Celluloid::SupervisionGroup
    supervise Runner
  end
end

require "blinkenstein/monitors/eve_skill_queue_monitor"

at_exit do
  Blink::Patterns.off
end
