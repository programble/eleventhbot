module EleventhBot
  class Channels
    include Plugin, Cinch::Plugin

    configru do
      option :blacklist, Hash, {}
      option :whitelist, Hash, {}
    end

    def plugin_exec(name, &block)
      if plugin = @bot.config.plugins.plugins.find {|p| p.plugin_name == name }
        plugin.instance_exec(&block)
      end
    end

    def initialize(*args)
      super

      config.blacklist.each do |plugin, channels|
        plugin_exec(plugin) do
          @blacklist_hook = hook(:pre, method: proc do |m|
            !channels.include?(m.channel.name)
          end)
        end
      end

      config.whitelist.each do |plugin, channels|
        plugin_exec(plugin) do
          @whitelist_hook = hook(:pre, method: proc do |m|
            channels.include?(m.channel.name)
          end)
        end
      end
    end

    def unregister
      super
      @bot.config.plugins.plugins.each do |plugin|
        plugin.instance_exec do
          __hooks(:pre).delete(@blacklist_hook)
          __hooks(:pre).delete(@whitelist_hook)
        end
      end
    end
  end
end
