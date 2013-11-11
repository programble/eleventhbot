require 'forecast_io'
require 'time-lord'
require 'wunderground'

module EleventhBot
  class Plugin::Weather
    include Plugin, Cinch::Plugin

    configru do
      option_group :forecastio do
        option_required :key, String
      end
      option_group :wunderground do
        option_required :key, String
      end
    end

    def initialize(*args)
      super
      @wunderground = Wunderground.new(config.wunderground['key'])
      ForecastIO.api_key = config.forecastio['key']
    end

    command :weather, /weather([fm])? (.+)/,
      'weather {location}: Get current weather conditions for a location'
    def weather(m, fm, location)
      data = @wunderground.conditions_for(location)
      return m.reply(data['response']['error']['description'], true) if data['response']['error']
      obs = data['current_observation']
      tu = fm ? 'f' : 'c'
      vu = fm ? 'mph' : 'kph'
      du = fm ? 'mi' : 'km'

      s = String.new
      s << obs['display_location']['full'] << ': '
      s << obs['weather'].downcase << ', '
      s << obs["temp_#{tu}"].to_s << "°#{tu.upcase}"
      if obs["temp_#{tu}"].to_f != obs["feelslike_#{tu}"].to_f
        s << ' (feels like ' << obs["feelslike_#{tu}"] << "°#{tu.upcase})"
      end
      s << ', ' << obs['relative_humidity'] << ' humidity, '
      s << 'wind from ' << obs['wind_dir'] << ' at '
      s << obs["wind_#{vu}"].to_s << ' ' << vu << ', '
      s << obs["visibility_#{du}"] << ' ' << du << ' of visibility '
      s << '[via Wunderground, as of '
      s << Time.at(obs['observation_epoch'].to_i).ago.to_words
      s << ']'

      m.reply(s)
    end
  end
end
