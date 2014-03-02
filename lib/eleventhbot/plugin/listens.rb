require 'time'
require 'open-uri'
require 'json'

module EleventhBot
  class Plugin::Listens
    include Plugin, Cinch::Plugin

    def account(m)
      redis.hget('listens:accounts', m.user.nick) || m.user.nick
    end

    def format_listen(listen)
      s = String.new
      s << listen['artist']
      s << ' - '
      s << listen['title']
      s << ' - '
      s << listen['album']
      s << ' ['
      s << Time.parse(listen['listenedAt']).ago.to_words
      s << ']'
    end

    command :Lassociate?, /Lassoc(?:iate)?\?(?: (\S+))?/,
      'Lassociate? [nick]: Show which Listens.ws account is associated with a nick'
    def Lassociate?(m, nick)
      nick ||= m.user.nick
      if assoc = redis.hget('listens:accounts', nick)
        m.reply("#{nick} is associated with the Listens.ws account '#{assoc}'")
      else
        m.reply("#{nick} is not associated with a Listens.ws account")
      end
    end

    command :Lassociate, /Lassoc(?:iate)? (\S+)/,
      'Lassociate {username}: Associate your nick with a Listens.ws account'
    def Lassociate(m, user)
      redis.hset('listens:accounts', m.user.nick, user)
      m.reply("Your nick is now associated with the Listens.ws account '#{user}'", true)
    end

    command :Last, /Last(?: (\S+))?/,
      'Last [username]: Show the last track listened to by a Listens.ws user'
    def Last(m, user)
      user ||= account(m)
      res = JSON.parse(open("http://api.listens.ws/~#{user}/listens?limit=1").read)
      p res
      m.reply("#{user}: #{format_listen(res['listens'][0])}")
    end
  end
end
