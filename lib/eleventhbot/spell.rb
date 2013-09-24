module EleventhBot
  class Spell
    include Plugin, Cinch::Plugin

    configru do
      option :checker, String, 'hunspell', %w[hunspell aspell]
      option :language, String, 'en_US'
    end

    WORD_REGEXP = /[\w']+/

    def initialize(*args)
      super
      require("ffi/#{config.checker}")
      @last = {}
    end

    def correct(s, i)
      case config.checker
      when 'hunspell'
        FFI::Hunspell.dict(config.language) do |dict|
          s.gsub!(WORD_REGEXP) do |w|
            if dict.check?(w) && i == 0
              w
            else
              suggest = dict.suggest(w)
              suggest.delete(w)
              suggest[i] || w
            end
          end
        end
        s
      when 'aspell'
        speller = FFI::Aspell::Speller.new(config.language)
        s.gsub(WORD_REGEXP) {|w| speller.suggestions(w)[i] || w }
      end
    end

    listen_to :message
    def listen(m)
      @last[m.channel] = m unless @bot.config.plugins.prefix === m.message
    end

    command :spell, /spell(\+*)(?: (.+))?/,
      "spell[+*] [text]: Correct spelling of text or last line in channel, replacing words with the nth suggestion based on the number of +'s"
    def spell(m, i, s)
      if s
        m.reply(correct(s, i.length), true)
      else
        last = @last[m.channel]
        if last.action?
          m.reply("* #{last.user.nick} #{correct(last.action_message, i.length)}")
        else
          m.reply("<#{last.user.nick}> #{correct(last.message, i.length)}")
        end
      end
    end
  end
end
