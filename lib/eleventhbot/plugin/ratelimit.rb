module EleventhBot
  class Plugin::RateLimit
    include Plugin, Cinch::Plugin

    configru do
      option :rate, Fixnum, 5
      option :time, Numeric, 1
      option :cooldown, Numeric, 5
    end

    def initialize(*args)
      super

      loaded_plugins.each do |plugin|
        plugin.instance_exec do
          @ratelimit_hook = hook(:pre, for: [:match],
                                 method: proc {|m| plugin(RateLimit).limit(m) })
        end
      end

      @rate = 0
      @time = Time.now
      @cooldown = Time.now
    end

    def __unregister
      super
      loaded_plugins.each do |plugin|
        plugin.instance_exec do
          __hooks(:pre).delete(@ratelimit_hook)
        end
      end
    end

    def limit(m)
      synchronize(:ratelimit) do
        if @cooldown > Time.now
          return false
        elsif Time.now - @time > config.time
          @time = Time.now
          @rate = 1
          return true
        elsif @rate == config.rate
          @cooldown = Time.now + config.cooldown
          m.reply('Rate limit exceeded')
          return false
        else
          @rate += 1
          return true
        end
      end
    end
  end
end
