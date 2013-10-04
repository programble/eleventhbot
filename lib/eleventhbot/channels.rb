module EleventhBot
  class Channels
    include Plugin, Cinch::Plugin

    configru do
      option :blacklist, Hash, {}
      option :whitelist, Hash, {}
    end

    def initialize(*args)
      super

      config.blacklist.each do |plugin, channels|
        loaded_plugin(plugin).instance_exec do
          @blacklist_hook = hook(:pre, method: proc do |m|
            !channels.include?(m.channel.name)
          end)
        end
      end

      config.whitelist.each do |plugin, channels|
        loaded_plugin(plugin).instance_exec do
          @whitelist_hook = hook(:pre, method: proc do |m|
            channels.include?(m.channel.name)
          end)
        end
      end
    end

    def unregister
      super
      loaded_plugins.each do |plugin|
        plugin.instance_exec do
          __hooks(:pre).delete(@blacklist_hook)
          __hooks(:pre).delete(@whitelist_hook)
        end
      end
    end
  end
end
