require 'pstore'

require 'lastfm'
require 'time-lord'

module EleventhBot
  class Lastfm
    include Plugin, Cinch::Plugin

    configru :lastfm do
      option_required :token, String
      option_required :secret, String

      option :pstore, String, 'lastfm.pstore'
    end

    def initialize(*args)
      super

      @pstore = PStore.new(config.pstore)
      @lastfm = ::Lastfm.new(config.token, config.secret)

      # TODO: Expire this cache?
      @chart_top = @lastfm.chart.get_top_artists(:limit => 0).map {|x| x['name'] }
    end

    def api_transaction(m, &block)
      begin
        block.call
      rescue ::Lastfm::ApiError => e
        m.reply("Last.fm error: #{e.message.strip}")
        raise
      end
    end

    def pstore_get(m)
      @pstore.transaction(true) { @pstore[m.user.nick] } || m.user.nick
    end

    def format_track(track, ago = true)
      s = String.new
      s << track['artist']['content']
      s << ' - '
      s << track['name']
      s << ' [' << track['album']['content'] << ']' if track['album']['content']
      return s unless ago
      s << ' ('
      s << (track['nowplaying'] ? 'Listening now' : Time.at(track['date']['uts'].to_i).ago.to_words)
      s << ')'
    end

    match /assoc(?:iate)?\??$/, method: :associate?
    match /assoc(?:iate)?\? (\S+)$/, method: :associate?
    def associate?(m, nick = nil)
      nick ||= m.user.nick
      assoc = @pstore.transaction(true) { @pstore[nick] }
      if assoc
        m.reply("#{nick} is associated with the Last.fm account '#{assoc}'")
      else
        m.reply("#{nick} is not associated with a Last.fm account")
      end
    end

    match /assoc(?:iate)? (\S+)$/, method: :associate
    def associate(m, user)
      @pstore.transaction { @pstore[m.user.nick] = user }
      m.reply("Your nick is now associated with the Last.fm account '#{user}'", true)
    end

    match /last( -\d+)?$/, method: :last
    match /last (-\d+ )?([^\s-]+)$/, method: :last
    def last(m, index, user = nil)
      user ||= pstore_get(m)
      index = index ? -index.to_i : 1
      api_transaction(m) do
        track = @lastfm.user.get_recent_tracks(user)[index - 1]
        m.reply("#{user}: #{format_track(track)}")
      end
    end
  end
end
