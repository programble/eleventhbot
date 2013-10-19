# Port of https://github.com/tsion/reggie

module EleventhBot
  class Plugin::Sed
    include Plugin, Cinch::Plugin

    match %r"((?:[^\\/]|\\.)*)/((?:[^\\/]|\\.)*)/([igx]*)", prefix: %r"^((?:#{Regexp.escape(Configru.irc.prefix)})*)s/", use_suffix: false
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
        target = memory.channel(m).find do |l|
          match.match(l.action? ? l.action_message : l.message)
        end
      else
        target = memory.user(m)[prefix.length - 1]
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
