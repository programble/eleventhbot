module EleventhBot
  class Plugin::Memory
    include Plugin, Cinch::Plugin

    configru do
      option :lines, Fixnum, 5
    end

    def initialize(*args)
      super
      @channel_lines = Hash.new {|h, k| h[k] = Array.new(config.lines) }
      @user_lines = Hash.new do |h, k|
        h[k] = Hash.new {|h, k| h[k] =  Array.new(config.lines) }
      end
    end

    listen_to :message
    def listen(m)
      # HACK: Ignore messages that are commands
      prefixes = bot.handlers.map(&:pattern).map(&:prefix).compact.uniq
      prefixes.delete(/^/)
      unless prefixes.any? {|p| m.match(p, m.action? ? :action : :other, true) }
        @channel_lines[m.channel].unshift(m).pop
        @user_lines[m.channel][m.user].unshift(m).pop
      end
    end

    def channel(m)
      @channel_lines[m.channel].compact
    end

    def user(m)
      @user_lines[m.channel][m.user].compact
    end
  end

  # Shortcut for other plugins
  module Plugin
    def memory
      plugin(Memory)
    end
  end
end
