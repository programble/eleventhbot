module EleventhBot
  class Channels
    include Plugin, Cinch::Plugin

    configru do
      option :blacklist, Hash, {}
      option :whitelist, Hash, {}
    end

    def initialize(*args)
      super

      blacklist_hook = proc do |m|
        if blacklist = plugin(Channels).config.blacklist[self.class.plugin_name]
          !blacklist.include?(m.channel.name)
        else
          true
        end
      end

      whitelist_hook = proc do |m|
        if whitelist = plugin(Channels).config.whitelist[self.class.plugin_name]
          whitelist.include?(m.channel.name)
        else
          true
        end
      end

      loaded_plugins.each do |plugin|
        plugin.instance_exec do
          @blacklist_hook = hook(:pre, method: blacklist_hook)
          @whitelist_hook = hook(:pre, method: whitelist_hook)
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

    command :blacklist, /blacklist (\S+)(?: (\S+))?/,
      'blacklist {plugin} [channel]: Blacklist a plugin from being used in a channel',
      group: :admin
    def blacklist(m, plugin, channel)
      return m.reply("#{plugin} does not exist", true) unless loaded_plugin(plugin)
      (config.blacklist[plugin] ||= Array.new) << (channel || m.channel.name)
      m.reply("#{plugin} blacklisted", true)
    end

    command :unblacklist, /unblacklist (\S+)(?: (\S+))?/,
      'unblacklist {plugin} [channel]: Unblacklist a plugin from being used in a channel',
      group: :admin
    def unblacklist(m, plugin, channel)
      return m.reply("#{plugin} is not blacklisted", true) unless config.blacklist[plugin]
      if config.blacklist[plugin].delete(channel || m.channel.name)
        m.reply("#{plugin} unblacklisted", true)
      else
        m.reply("#{plugin} not blacklisted in #{channel || m.channel.name}", true)
      end
    end

    command :whitelist, /whitelist (\S+)(?: (\S+))?/,
      'whitelist {plugin} [channel]: Whitelist a plugin to only be used in a channel',
      group: :admin
    def whitelist(m, plugin, channel)
      return m.reply("#{plugin} does not exist", true) unless loaded_plugin(plugin)
      (config.whitelist[plugin] ||= Array.new) << (channel || m.channel.name)
      m.reply("#{plugin} whitelisted", true)
    end
 
    command :unwhitelist, /unwhitelist (\S+)(?: (\S+))?/,
      'unwhitelist {plugin} [channel]: Unwhitelist a plugin from only being used in a channel',
      group: :admin
    def unwhitelist(m, plugin, channel)
      return m.reply("#{plugin} is not whitelisted", true) unless config.whitelist[plugin]
      if config.whitelist[plugin].delete(channel || m.channel.name)
        m.reply("#{plugin} unwhitelisted", true)
      else
        m.reply("#{plugin} not whitelisted in #{channel || m.channel.name}", true)
      end
    end
  end
end
