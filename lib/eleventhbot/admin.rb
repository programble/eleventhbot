module EleventhBot
  class Admin
    include Plugin, Cinch::Plugin

    configru do
      option_array :masks, String
    end

    def admin?(m)
      admin = config.masks.any? {|mask| m.user.match(mask) }
      m.reply('You are not an administrator', true) unless admin
      admin
    end

    command :say, /say (\S+) (.+)/,
      'say {target} {thing}: Say something'
    def say(m, target, s)
      Target(target).msg(s) if admin?(m)
    end

    command :action, /action (\S+) (.+)/,
      'action {target} {thing}: Do something'
    def action(m, target, s)
      Target(target).action(s) if admin?(m)
    end

    command :nick, /nick(?: (\S+))?/,
      "nick [nick]: Change the bot's nick"
    def nick(m, nick)
      @bot.nick = nick || Configru.irc.nick if admin?(m)
    end

    command :join, /join (\S+)(?: (\S+))?/,
      'join {channel} [key]: Join a channel'
    def join(m, channel, key)
      @bot.join(channel, key) if admin?(m)
    end

    command :part, /part (\S+)(?: (.+))?/,
      'part {channel} [reason]: Leave a channel'
    def part(m, channel, reason)
      @bot.part(channel, reason) if admin?(m)
    end

    def available_plugins
      @bot.config.plugins.plugins.select {|p| p.include? Plugin }
    end

    def available_plugin(name)
      available_plugins.find {|p| p.plugin_name == name }
    end

    def enabled_plugins
      @bot.plugins.select {|p| p.is_a? Plugin }
    end

    def enabled_plugin(name)
      enabled_plugins.find {|p| p.class.plugin_name == name }
    end

    command :plugins, /plugins/,
      'plugins: List loaded plugins'
    def plugins(m)
      return unless admin?(m)
      plugins = available_plugins.map do |plugin|
        if enabled_plugin(plugin.plugin_name)
          plugin.plugin_name
        else
          "[#{plugin.plugin_name}]"
        end
      end
      m.reply(plugins.join(' '), true)
    end

    command :disable, /disable (\S+)/,
      'disable {plugin}: Disable a plugin'
    def disable(m, name)
      return unless admin?(m)
      if plugin = enabled_plugin(name)
        @bot.plugins.unregister_plugin(plugin)
        m.reply("#{name} disabled", true)
      else
        m.reply("#{name} is not enabled", true)
      end
    end

    command :enable, /enable (\S+)/,
      'enable {plugin}: Enable a plugin'
    def enable(m, name)
      return unless admin?(m)
      return m.reply("#{name} is already enabled", true) if enabled_plugin(name)
      if plugin = available_plugin(name)
        @bot.plugins.register_plugin(plugin)
        m.reply("#{name} enabled", true)
      else
        m.reply("#{name} does not exist", true)
      end
    end

    command :reload, /reload (\S+)/,
      'reload {plugin}: Reload a plugin'
    def reload(m, name)
      return unless admin?(m)

      if plugin = enabled_plugin(name)
        @bot.plugins.unregister_plugin(plugin)
      else
        return m.reply("#{name} is not enabled", true)
      end

      begin
        load("eleventhbot/#{name}.rb")
      rescue LoadError => e
        return m.reply(e.message.capitalize, true)
      end

      if plugin = available_plugin(name)
        @bot.plugins.register_plugin(plugin)
        m.reply("#{name} reloaded", true)
      else
        m.reply("#{name} does not exist", true)
      end
    end
  end
end
