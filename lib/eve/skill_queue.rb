require "eve/base"

class Eve::SkillQueue < Eve::Base
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
      parse_date(@response.fetch("eveapi", {}).fetch("currentTime", {}))
    end

    def cached_until
      parse_date(@response.fetch("eveapi", {}).fetch("cachedUntil", {}))
    end

    def end_time
      parse_date(last_skill.fetch("endTime", ""))
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

