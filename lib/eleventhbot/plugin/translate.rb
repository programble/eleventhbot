# encoding: utf-8

require 'bing_translator'

module EleventhBot
  class Plugin::Translate
    include Plugin, Cinch::Plugin

    configru do
      option_required :bing_client_id, String
      option_required :bing_client_secret, String
    end

    def initialize(*args)
      super

      @bing = BingTranslator.new(config['bing_client_id'], config['bing_client_secret'])
      @supported_langs = @bing.supported_language_codes

      names = @bing.language_names(@supported_langs)
      @language_names = {}
      @supported_langs.each_with_index do |code, i|
        @language_names[code] = names[i]
      end
    end

    command :trans, /trans (\S+) (\S+) (.+)/,
      'trans {from} {to} {text}: Translate from one language to another'
    def trans(m, from, to, text)
      return m.reply('Invalid target language') unless @supported_langs.include?(to)

      if from == 'auto'
        m.reply(@bing.translate(text, to: to))
      else
        return m.reply('Invalid source language') unless @supported_langs.include?(from)
        m.reply(@bing.translate(text, from: from, to: to))
      end
    end

    command :detect, /detect (.+)/,
      'detect {text}: Detect the language of the text'
    def detect(m, text)
      m.reply(@bing.detect(text))
    end

    command :langname, /langname (\S+)/,
      'langname {code}: Find the name of the language with the given code'
    def langname(m, code)
      return m.reply('Unsupported language code') unless @supported_langs.include?(code)
      m.reply(@language_names[code])
    end
  end
end
