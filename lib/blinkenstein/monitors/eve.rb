require 'celluloid'
require 'httparty'
require 'nokogiri'

module Blinkenstein 
  class EveMonitor 
    include Celluloid
    include HTTParty

    base_uri 'https://api.eveonline.com'

    def initialize(blink)
      @blink   = blink
      @options = YAML.load(File.read(File.expand_path('~/.blinkenstein')))
    end

    def refresh
      response = self.class.get('/char/SkillQueue.xml.aspx', query: @options)
      cached_for_seconds, hours_until_empty = parse(response)

      puts "Cached for #{cached_for_seconds} seconds"
      puts "Skill queue empty in #{hours_until_empty} hours"

      update_blink(hours_until_empty)
    ensure
      after(cached_for_seconds || 60) do
        refresh
      end
    end

    def parse(response)
      skills_for_hours   = -1
      cached_for_seconds = 60

      currentTime = DateTime.strptime(response["eveapi"]['currentTime'], '%Y-%m-%d %H:%M:%S')
      cachedUntil = DateTime.strptime(response["eveapi"]['cachedUntil'], '%Y-%m-%d %H:%M:%S')
      skills      = ([] << response["eveapi"]["result"]["rowset"]["row"]).flatten.last

      cached_for_seconds = ((cachedUntil - currentTime) * 24 * 60 * 60).to_i
      
      puts skills.inspect
      if skills && skills["endTime"] && skills['endTime'] != '' 
        endTime = DateTime.strptime(skills["endTime"], '%Y-%m-%d %H:%M:%S') 
        skills_for_hours   = ((endTime - currentTime)     * 24).to_i
      end
      [cached_for_seconds, skills_for_hours]
    ensure 
      [cached_for_seconds, skills_for_hours]
    end


    def update_blink(hours_until_empty)
      case hours_until_empty
      when -1..8   then panic
      when 9..24   then nervous
      when Integer then cool
      else error
      end
    end

    def cool
      puts "Everything is cool"
      @blink.breath("#00ff00", 4, 0.2)
    end

    def nervous
      puts "There's room in the queue"
      @blink.breath("#ff0000", 3, 0.3)
    end

    def panic
      puts "Queue runs out soon."
      @blink.police
    end

    def error
      puts "Ehm. Something is wrong"
      @blink.breath("#ff0000", 0.25, 0.75)
    end
  end
end
