module EleventhBot
  class Plugin::Meep
    include Plugin, Cinch::Plugin

    match /`meep/, use_prefix: false
    def execute(m)
      m.reply('meep')
    end
  end
end
