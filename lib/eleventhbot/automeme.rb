require 'open-uri'

module EleventhBot
  class Automeme
    include Plugin, Cinch::Plugin

    def initialize(*args)
      super
      @memes = []
    end

    command :meme, /(?:auto)?meme(?: (.+))?/,
      'meme [target]: Generate a random meme, optionally at a target'
    def meme(m, target)
      @memes = open('http://api.automeme.net/text').read.split("\n") if @memes.empty?
      m.reply("#{target + ': ' if target}#{@memes.shift}")
    end
  end
end
