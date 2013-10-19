# Port of https://github.com/tsion/reggie

module EleventhBot
  class Plugin::Sed
    include Plugin, Cinch::Plugin

    configru do
      option :memory, Fixnum, 5
    end

    def initialize(*args)
      super
      @lines = Hash.new do |h, k|
        h[k] = Hash.new do |h, k|
          h[k] = Array.new(config.memory)
        end
      end
    end

    listen_to :message
    def listen(m)
      # FIXME: Find a better way to ignore commands
      unless @bot.config.plugins.prefix =~ m.message || m.message.start_with?('s/')
        @lines[m.channel][:channel].unshift(m).pop
        @lines[m.channel][m.user].unshift(m).pop
      end
    end

    match %r"^((?:#{Regexp.escape(Configru.irc.prefix)})*)s/((?:[^\\/]|\\.)*)/((?:[^\\/]|\\.)*)/([igx]*)", use_prefix: false, use_suffix: false
    def execute(m, prefix, match, replace, flags)
      replace.gsub!(/(?<!\\)((?:\\\\)*)\\\//, '\1/') # Unescape escaped /'s

      options = 0
      options |= Regexp::IGNORECASE if flags.include? ?i
      options |= Regexp::EXTENDED if flags.include? ?x

      begin
        match = Regexp.new(match, options)
      rescue RegexpError => err
        m.reply(err.message.capitalize, true)
        return
      end

      if prefix.empty?
        target = @lines[m.channel][:channel].find do |l|
          match.match(l.action? ? l.action_message : l.message)
        end
      else
        target = @lines[m.channel][m.user][prefix.length - 1]
      end
      return unless target

      method = flags.include?(?g) ? :gsub! : :sub!
      if target.action?
        target.action_message.send(method, match, replace)
        m.reply("* #{target.user.nick} #{target.action_message}")
      else
        target.message.send(method, match, replace)
        m.reply("<#{target.user.nick}> #{target.message}")
      end
    end
  end
end
