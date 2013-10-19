require 'time'

require 'json'
require 'open-uri'
require 'time-lord'

module EleventhBot
  class Plugin::Github
    include Plugin, Cinch::Plugin

    command :ghstatus, /ghstatus/,
      'ghstatus: Get the last Github Status message'
    def ghstatus(m)
      json = JSON.parse(open('https://status.github.com/api/last-message.json').read)
      m.reply("#{json['body']} (#{Time.parse(json['created_on']).ago.to_words})", true)
    end
  end
end
