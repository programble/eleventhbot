require 'uri'

require 'redis'

module EleventhBot
  class Plugin::Redis
    include Plugin, Cinch::Plugin

    configru do
      option :uri, String, 'redis://localhost:6379/0' do
        transform {|u| URI(u) }
      end
    end

    attr_reader :redis

    def initialize(*args)
      super
      @redis = ::Redis.new(url: config.uri)
    end
  end

  # Shortcut for other plugins
  module Plugin
    def redis
      plugin(Redis).redis
    end
  end
end
