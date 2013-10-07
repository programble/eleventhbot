require 'cgi'
require 'net/http'
require 'open-uri'
require 'stringio'
require 'timeout'

require 'fastimage'
require 'twitter'

module EleventhBot
  class Snarf
    include Plugin, Cinch::Plugin

    configru do
      option :timeout, Fixnum, 5

      option_group :cache do
        option :limit, Fixnum, 50
        option :ttl, Fixnum, 3600
      end

      option_group :http do
        option_group :limits do
          option :redirects, Fixnum, 5
          option :stream, Fixnum, 512
        end

        option :useragent, String, 'Mozilla/5.0 (X11; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/24.0'
      end

      option_group :twitter do
        option :key, String, ''
        option :secret, String, ''
      end
    end

    class LRUTTLHash < Hash
      def initialize(limit, ttl)
        super()
        @limit = limit
        @ttl = ttl
        @times = Hash.new
        @lru = Array.new
      end

      def fetch(key, &block)
        @lru.delete(key)
        @lru.unshift(key)
        @lru.pop.tap {|x| delete(x) && @times.delete(x) } if @lru.length > @limit

        delete(key) if include?(key) && Time.now - @times[key] >= @ttl
        @times[key] = Time.now unless include?(key)

        value = super
        store(key, value)
        value
      end
    end

    def initialize(*args)
      super
      @cache = LRUTTLHash.new(config.cache.limit, config.cache.ttl)
      if !config.twitter['key'].empty?
        @twitter = Twitter::REST::Client.new do |c|
          c.consumer_key = config.twitter['key']
          c.consumer_secret = config.twitter['secret']
        end
      end
    end

    def dagd(uri)
      open("http://da.gd/s?url=#{URI.escape(uri.to_s)}&strip=1", 'r', &:read)
    rescue OpenURI::HTTPError => e
      e.to_s
    end

    def snarf_html(buffer)
      if match = /<title>(.+)<\/title>/mi.match(buffer)
        '"' + CGI.unescape_html(match[1].gsub(/\s+/, ' ').strip) + '"'
      end
    end

    def snarf_image(buffer)
      image = FastImage.new(StringIO.new(buffer))
      image.size.join('x') + ' ' + image.type.to_s.upcase if image.type && image.size
    end

    def snarf_stream(res)
      method =
        case res['Content-type'].split(';').first
        when 'text/html', 'application/xhtml+xml'
          :snarf_html
        when %r"^image/"
          :snarf_image
        else
          warn "cannot snarf #{res['Content-type']}"
          return
        end

      buffer = String.new
      snarfed = nil
      begin
        catch(:halt) do
          res.read_body do |chunk|
            buffer << chunk
            if snarfed = send(method, buffer)
              throw :halt
            elsif buffer.length > config.http.limits.stream * 1000
              warn 'stream limit'
              throw :halt
            end
          end
        end
      rescue Zlib::BufError
        # Raised when we stop streaming a compressed response
      end

      snarfed
    end

    def snarf_http(uri, depth = 0)
      if depth > config.http.limits.redirects
        warn 'redirect limit'
        return
      end

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        #req = Net::HTTP::Get.new(uri) # Ruby 2.0
        req = Net::HTTP::Get.new(uri.request_uri)
        req['Host'] = uri.host # Ruby 2.0 does this for us
        req['User-agent'] = config.http.useragent

        http.request(req) do |res|
          if res.is_a? Net::HTTPRedirection
            return snarf_http(URI(res['Location']), depth + 1)
          elsif res.is_a? Net::HTTPSuccess
            if snarfed = snarf_stream(res)
              return snarfed += " <#{dagd(uri)}>"
            end
          else
            warn res.inspect
          end
        end
      end
      return
    end

    def snarf_tweet(uri)
      return unless @twitter
      if uri.host == 'twitter.com' && match = %r"/status/(\d+)".match(uri.request_uri)
        tweet = @twitter.status(match[1].to_i)
        s = String.new
        favrt = Array.new
        favrt << "#{tweet.favorite_count} fav" unless tweet.favorite_count.zero?
        favrt << "#{tweet.retweet_count} rt" unless tweet.retweet_count.zero?
        s << '(' << favrt.join(' ') << ') ' unless favrt.empty?
        s << '@' << Format(:bold, tweet.user.screen_name) << ': '
        s << CGI.unescapeHTML(tweet.text).gsub("\n", ' ')
      end
    rescue Twitter::Error => e
      warn e.inspect
      return
    end

    match /(https?:\/\/[^ >]+)/, use_prefix: false, use_suffix: false, method: :snarf
    def snarf(m, uri)
      uri = URI(uri)
      snarfed = @cache.fetch(uri) do
        begin
          Timeout.timeout(config.timeout) do
            snarf_tweet(uri) || snarf_http(uri)
          end
        rescue Timeout::Error
          warn 'timeout'
          nil
        end
      end
      m.reply(snarfed)
    end
  end
end
