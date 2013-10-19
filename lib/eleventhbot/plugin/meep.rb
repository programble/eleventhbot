module EleventhBot
  class Plugin::Meep
    include Plugin, Cinch::Plugin

    match /meep/, prefix: /^`/
    def execute(m)
      m.reply('meep')
    end
  end
end
