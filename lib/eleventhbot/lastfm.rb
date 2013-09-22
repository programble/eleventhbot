require 'pstore'

require 'future'
require 'lastfm'
require 'time-lord'

module EleventhBot
  class Lastfm
    include Plugin, Cinch::Plugin

    configru do
      option_required :token, String
      option_required :secret, String

      option :pstore, String, 'lastfm.pstore'
      option :chart, String, 'lastfm.chart'
    end

    def initialize(*args)
      super

      @pstore = PStore.new(config.pstore)
      @lastfm = ::Lastfm.new(config.token, config.secret)

      # TODO: Expire this cache?
      @chart_top = future do
        if File.exist? config.chart
          File.readlines(config.chart).map(&:chomp)
        else
          chart = @lastfm.chart.get_top_artists(:limit => 0).map {|x| x['name'] }
          File.open(config.chart, 'w') {|f| f.puts(chart) }
          chart
        end
      end
    end

    def api_transaction(m)
      begin
        yield
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

    match /assoc(?:iate)?\?(?: (\S+))?/, method: :associate?
    def associate?(m, nick)
      nick ||= m.user.nick
      assoc = @pstore.transaction(true) { @pstore[nick] }
      if assoc
        m.reply("#{nick} is associated with the Last.fm account '#{assoc}'")
      else
        m.reply("#{nick} is not associated with a Last.fm account")
      end
    end

    match /assoc(?:iate)? (\S+)/, method: :associate
    def associate(m, user)
      @pstore.transaction { @pstore[m.user.nick] = user }
      m.reply("Your nick is now associated with the Last.fm account '#{user}'", true)
    end

    match /last(?: -(\d+))?(?: (\S+))?/, method: :last
    def last(m, index, user)
      user ||= pstore_get(m)
      index = index ? index.to_i : 1
      api_transaction(m) do
        track = @lastfm.user.get_recent_tracks(user)[index - 1]
        m.reply("#{user}: #{format_track(track)}")
      end
    end

    match /inform (#\S+)/, method: :inform
    def inform(m, channel)
      user = pstore_get(m)
      return m.reply("Your nick is not associated with a Last.fm account", true) unless user
      api_transaction(m) do
        track = @lastfm.user.get_recent_tracks(user).first
        if track['nowplaying']
          Channel(channel).msg("* #{m.user.nick} is listening to #{format_track(track, false)}")
        else
          Channel(channel).msg("* #{m.user.nick} last listened to #{format_track(track)}")
        end
      end
    end

    match /first(?: (\S+))?/, method: :first
    def first(m, user)
      user ||= pstore_get(m)
      api_transaction(m) do
        track = @lastfm.user.get_recent_tracks(:user => user,
                                               :limit => 1,
                                               :page => 999999999)
        m.reply("#{user}: #{format_track(track)}")
      end
    end

    match /plays(?: (\S+))?/, method: :plays
    def plays(m, user)
      user ||= pstore_get(m)
      api_transaction(m) do
        info = @lastfm.user.get_info(user)
        registered = Time.at(info['registered']['unixtime'].to_i)
        m.reply("#{user}: #{info['playcount']} plays since #{registered.strftime('%d %b %Y')}")
      end
    end

    match /compare (\S+)(?: (\S+))?/, method: :compare
    def compare(m, user1, user2)
      user2 ||= pstore_get(m)
      api_transaction(m) do
        compare = @lastfm.tasteometer.compare(:user, :user, user1, user2)
        score = compare['score'].to_f * 100
        matches = compare['artists']['matches'].to_i
        artists = compare['artists']['artist'].map {|x| x['name'] } if matches > 0

        s = String.new
        s << "#{user1} and #{user2} have "
        s << '%0.2f' % score << '% similar taste '
        if matches > 0
          s << "(#{matches} artist#{matches == 1 || ?s} in common"
          s << (matches > artists.length ? ', including: ' : ': ')
          s << artists.join(', ')
          s << ')'
        end

        m.reply(s)
      end
    end

    match /bestfriend(?: (\S+))?/, method: :bestfriend
    def bestfriend(m, user)
      user ||= pstore_get(m)
      api_transaction(m) do
        friends = @lastfm.user.get_friends(:user => user, :limit => 0).map {|x| x['name'] }
        scores = Hash.new
        friends.each do |friend|
          scores[friend] = @lastfm.tasteometer.compare(:user, :user, user, friend)['score'].to_f
        end
        bestfriend = scores.max {|a, b| a[1] <=> b[1] }.first
        m.reply("#{user}'s best friend is #{bestfriend}")
      end
    end

    def calculate_hipster(m, period, user)
      api_transaction(m) do
        user_top = @lastfm.user.get_top_artists(:user => user, :period => period)
        total_weight = user_top.map {|x| x['playcount'].to_i }.reduce(:+)
        score = 0
        user_top.each do |artist|
          score += artist['playcount'].to_i if @chart_top.include?(artist['name'])
        end
        score.to_f / total_weight * 100.0
      end
    end

    match /hipster(?: -(\S+))?(?: (\S+))?/, method: :hipster
    def hipster(m, period, user)
      user ||= pstore_get(m)
      hipster = calculate_hipster(m, period || 'overall', user)
      m.reply("#{user} is #{'%0.2f' % hipster}% mainstream")
    end

    match /hipsterbattle (?:-(\S+) )?(.+)/, method: :hipsterbattle
    def hipsterbattle(m, period, users)
      hipsters = Hash.new
      users.split[0..4].each do |user|
        hipsters[user] = calculate_hipster(m, period || 'overall', user)
      end
      m.reply(hipsters.sort {|a, b| a[1] <=> b[1] }.map {|x| "#{x[0]}: #{'%0.2f' % x[1]}% mainstream" }.join(', '))
    end

    match /topartists(?: -(\S+))?(?: (\S+))?/, method: :topartists
    def topartists(m, period, user)
      user ||= pstore_get(m)
      api_transaction(m) do
        top = @lastfm.user.get_top_artists(:user => user,
                                           :period => period || 'overall',
                                           :limit => 5)
        s = top.map {|x| "#{x['name']} (#{x['playcount']} plays)" }.join(', ')
        m.reply("#{user}: #{s}")
      end
    end

    match /topalbums(?: -(\S+))?(?: (\S+))?/, method: :topalbums
    def topalbums(m, period, user)
      user ||= pstore_get(m)
      api_transaction(m) do
        top = @lastfm.user.get_top_albums(:user => user,
                                          :period => period || 'overall',
                                          :limit => 5)
        s = top.map {|x| "#{x['artist']['name']} - #{x['name']} (#{x['playcount']} plays)" }.join(', ')
        m.reply("#{user}: #{s}")
      end
    end

    match /toptracks(?: -(\S+))?(?: (\S+))?/, method: :toptracks
    def toptracks(m, period, user)
      user ||= pstore_get(m)
      api_transaction(m) do
        top = @lastfm.user.get_top_tracks(:user => user,
                                          :period => period || 'overall',
                                          :limit => 5)
        s = top.map {|x| "#{x['artist']['name']} - #{x['name']} (#{x['playcount']} plays)" }.join(', ')
        m.reply("#{user}: #{s}")
      end
    end
  end
end
