require 'httparty'

module Eve

  class Base 
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

    def parse_date(eve_date)
      DateTime.strptime(eve_date, '%Y-%m-%d %H:%M:%S') rescue nil
    end
  end

end
