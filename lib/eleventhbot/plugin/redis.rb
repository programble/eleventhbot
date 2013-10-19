require 'uri'

require 'redis'

module EleventhBot
  class Plugin::Redis
    include Plugin, Cinch::Plugin

    configru do
      option :uri, String, 'redis://localhost:6379/' do
        transform {|u| URI(u) }
      end
    end

    attr_reader :redis

    def initialize(*args)
      super
      @redis = ::Redis.new(host: config.uri.host, port: config.uri.port,
                           password: config.uri.password)
    end
  end

  # Shortcut for other plugins
  module Plugin
    def redis
      plugin(Redis).redis
    end
  end
end
