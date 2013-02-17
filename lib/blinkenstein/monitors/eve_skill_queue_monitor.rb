require 'blink1-patterns'
require 'eve/skill_queue'

module Blinkenstein 
  class EveSkillQueueMonitor 
    def refresh 
      update_blink
    end

    def hours_left
      @skillQueue ||= Eve::SkillQueue.new
      @skillQueue.hours_left
    end

    def update_blink
      case 
      when hours_left < 0 then error
      when hours_left < 8 && hours_left >= 0  then panic
      when hours_left > 8 && hours_left <= 24 then nervous
      when hours_left > 24 then cool 
      end
    end

    def cool 
      puts "Everything is cool. #{hours_left}h left."
      Blink::Patterns.breath("#00ff00", 4, 0.2)
    end

    def nervous
      puts "There's room in the queue. #{hours_left}h left."
      Blink::Patterns.breath("#ff0000", 3, 0.3)
    end

    def panic
      puts "Queue runs out soon. #{hours_left}h left."
      Blink::Patterns.police
    end

    def error
      puts "Ehm. Something is wrong"
      Blink::Patterns.breath("#ff0000", 0.25, 0.75)
    end
  end
end
