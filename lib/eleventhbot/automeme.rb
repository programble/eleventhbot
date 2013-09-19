require 'open-uri'

module EleventhBot
  class Automeme
    include Plugin, Cinch::Plugin

    def initialize(*args)
      super
      @memes = []
    end

    match /(?:auto)?meme$/
    match /(?:auto)?meme (.+)/
    def execute(m, target = nil)
      @memes = open('http://api.automeme.net/text').read.split("\n") if @memes.empty?
      m.reply("#{target + ': ' if target}#{@memes.shift}")
    end
  end
end
