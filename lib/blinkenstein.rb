require "celluloid"

require "blinkenstein/version"
require "blinkenstein/runner"

module Blinkenstein
  class SupervisionGroup < Celluloid::SupervisionGroup
    supervise Runner
  end
end

require "blinkenstein/monitors/eve_skill_queue_monitor"


