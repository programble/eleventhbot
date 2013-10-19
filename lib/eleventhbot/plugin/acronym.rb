module EleventhBot
  class Plugin::Acronym
    include Plugin, Cinch::Plugin

    configru do
      option :words, String, '/usr/share/dict/words' do
        validate {|x| File.file? x }
      end
    end

    def initialize(*args)
      super
      @words = File.readlines(config.words).map(&:strip).group_by {|s| s.chr }
    end

    command :acronym, /(?:acronym ([a-zA-Z]+)|([A-Z]+))/,
      'acronym {acronym}: Suggest a possible meaning of an acronym'
    def acronym(m, a, b) # Two possible regexp groups
      m.reply((a || b).downcase.chars.map {|c| @words[c].sample.capitalize }.join(' '))
    end
  end
end
