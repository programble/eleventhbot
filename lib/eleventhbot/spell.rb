require 'ffi/aspell'

module EleventhBot
  class Spell
    include Cinch::Plugin

    def initialize(*args)
      super(*args)

      @last = {}
      @speller = FFI::Aspell::Speller.new
    end

    def correct(s, i)
      s.gsub(/[\w']+/) {|w| @speller.suggestions(w)[i] || w }
    end

    listen_to :message
    def listen(m)
      @last[m.channel] = m unless @bot.config.plugins.prefix === m.message
    end

    match /spell(\+*)$/, method: :spell_last
    def spell_last(m, i)
      last = @last[m.channel]
      if last.action?
        m.reply("* #{last.user.nick} #{correct(last.action_message, i.length)}")
      else
        m.reply("<#{last.user.nick}> #{correct(last.message, i.length)}")
      end
    end

    match /spell(\+*) (.+)/, method: :spell
    def spell(m, i, s)
      m.reply(correct(s, i.length), true)
    end
  end
end
