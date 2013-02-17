require 'celluloid'
require 'httparty'
require 'blink1-patterns'
require 'vcr'

module Blinkenstein 
  class Eve
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

    def self.parse_date(eve_date)
      DateTime.strptime(eve_date, '%Y-%m-%d %H:%M:%S') rescue nil
    end
  end

  class Response
    def initialize(response)
      @response = response
    end


  end

  class SkillQueue < Eve
    attr_reader :expire_time

    def initialize
      @expire_time = Time.now - 1
    end

    def hours_left
      refresh

      return ((end_time - current_time) * 24).to_i if end_time 
      return  0 if paused? || empty?
      return -1 if blocked?
      -1
    end

    def paused?
      return false if blocked?

      last_skill.fetch("endTime", false) == "" 
    end

    def blocked?
      @response.fetch("eveapi", {}).fetch("error", false)
    end

    def empty?
      return false if blocked?
      
      last_skill.empty?
    end

    def last_skill
      @last_skill ||= Array[@response.fetch("eveapi", {}).fetch("result", {}).fetch("rowset", {}).fetch("row", {})].flatten.last
    end

    def current_time 
      Eve.parse_date(@response.fetch("eveapi", {}).fetch("currentTime", {}))
    end

    def cached_until
      Eve.parse_date(@response.fetch("eveapi", {}).fetch("cachedUntil", {}))
    end

    def end_time
      Eve.parse_date(last_skill.fetch("endTime", ""))
    end

    def update_cache
      if current_time && cached_until
        @expire_time = Time.now + ((cached_until - current_time) * 24 * 60 * 60).to_i
      else
        @expire_time = Time.now + 60 
      end
    end

    def refresh 
      return if @response && Time.now < @expire_time 

      @response = self.class.get('/char/SkillQueue.xml.aspx', query: query)
      update_cache 
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
