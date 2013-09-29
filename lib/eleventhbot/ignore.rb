module EleventhBot
  class Ignore
    include Plugin, Cinch::Plugin

    configru do
      option_array :masks, String
    end

    def plugins_exec(&block)
      @bot.config.plugins.plugins.each do |plugin|
        plugin.instance_exec(&block)
      end
    end

    def initialize(*args)
      super

      ignore_hook = proc do |m|
        !Configru.ignore.masks.any? {|mask| m.user.match(mask) }
      end

      plugins_exec do
        @ignore_hook = hook(:pre, method: ignore_hook)
      end
    end

    def unregister
      plugins_exec do
        __hooks(:pre).delete(@ignore_hook)
      end
    end
  end
end
