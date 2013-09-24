module EleventhBot
  class Help
    include Plugin, Cinch::Plugin

    def bot_plugins
      @bot.config.plugins.plugins.select {|p| p.include? Plugin }
    end

    command :list, /list(?: (\S+))?/,
      'list [plugin]: List all plugins or help topics provided by a plugin'
    def list(m, name)
      if name
        plugin = bot_plugins.find {|p| p.plugin_name == name }
        return unless plugin
        if plugin.help_topics.empty?
          m.reply("#{name} provides no help topics", true)
        else
          m.reply("#{name}: #{plugin.help_topics.keys.join(', ')}", true)
        end
      else
        plugins = bot_plugins.map(&:plugin_name)
        m.reply(plugins.join(', '), true)
      end
    end

    command :provides?, /provides\?? (\S+)/,
      'provides? {topic}: Show which plugin provides a help topic'
    def provides?(m, topic)
      plugin = bot_plugins.find {|p| p.help_topics.include? topic }
      if plugin
        m.reply("#{topic} is provided by #{plugin.plugin_name}", true)
      else
        m.reply("#{topic} is not provided by any plugin", true)
      end
    end

    command :help, /help(?: (\S+))?/,
      'help [topic]: Show the help text for a topic'
    def help(m, topic)
      topic = 'help' unless topic
      plugin = bot_plugins.find {|p| p.help_topics.include? topic }
      if plugin
        m.reply(plugin.help_topics[topic], true)
      else
        m.reply("#{topic} does not exist", true)
      end
    end
  end
end
