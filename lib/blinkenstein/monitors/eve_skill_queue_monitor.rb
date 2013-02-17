require 'celluloid'
require 'httparty'
require 'blink1-patterns'
require 'vcr'

module Blinkenstein 
  class EveClient
    include HTTParty
    base_uri 'https://api.eveonline.com'

    VALID_KEYS = [:characterID, :keyID, :vCode]

    def load_config
      config = {}

      begin
        config = YAML.load(File.read(File.expand_path('~/.eve-api')))
      rescue Errno::ENOENT
        raise "No ~/.eve-monitor config. The skill queue monitor can't start..." 
      rescue Psych::SyntaxError
        raise "Invalid syntax in ~/.eve-api. The skill queue monitor can't start..." 
      end

      config
    end

    def configure
      config = load_config
      query  = {}

      config.each do |k,v| 
        query[k.to_sym] = v if VALID_KEYS.include? k.to_sym
      end

      query
    end

    def query
      @query ||= configure
    end
  end


  class SkillQueue < EveClient

    def initialize
      @cached_until = Time.now - 1
      @hours_left   = -1
    end

    def hours_left
      return @hours_left if Time.now < @cached_until 

      puts "Fetching Update"
      
      response = self.class.get('/char/SkillQueue.xml.aspx', query: query)
      parse(response)

      @hours_left
    end
    
    def parse(response)
      @hours_left   = -1
      @cached_until = Time.now + 60

      currentTime = DateTime.strptime(response["eveapi"]['currentTime'], '%Y-%m-%d %H:%M:%S')
      cachedUntil = DateTime.strptime(response["eveapi"]['cachedUntil'], '%Y-%m-%d %H:%M:%S')
      skills      = ([] << response["eveapi"]["result"]["rowset"]["row"]).flatten.last

      @cached_until = Time.now + ((cachedUntil - currentTime) * 24 * 60 * 60).to_i
      
      if skills && skills["endTime"] && skills['endTime'] != '' 
        endTime = DateTime.strptime(skills["endTime"], '%Y-%m-%d %H:%M:%S') 
        @hours_left = ((endTime - currentTime)     * 24).to_i
      end
    end
  end


  class EveSkillQueueMonitor 
    def refresh 
      update_blink
    end

    def hours_left
      @skillQueue ||= SkillQueue.new
      @skillQueue.hours_left
    end

    def update_blink
      case 
      when hours_left < 8                      then panic
      when hours_left > 8  && hours_left <= 24 then nervous
      when hours_left > 24                     then cool 
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
