require 'cgi'
require 'net/http'
require 'timeout'

module EleventhBot
  class Snarf
    include Plugin, Cinch::Plugin

    configru do
      option :timeout, Fixnum, 10

      option_group :cache do
        option :limit, Fixnum, 50
        option :ttl, Fixnum, 3600
      end

      option_group :http do
        option_group :limits do
          option :redirects, Fixnum, 10
          option :stream, Fixnum, 512
        end

        option :useragent, String, 'Mozilla/5.0 (X11; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/24.0'
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
        delete(@lru.pop) if @lru.length > @limit

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
    end

    TITLE_REGEXP = /<title>(.+)<\/title>/i
    def snarf_html(buffer)
      if match = TITLE_REGEXP.match(buffer)
        '"' + CGI.unescape_html(match[1].gsub(/\s+/, ' ')) + '"'
      end
    end

    def snarf_stream(res)
      method =
        case res['Content-type'].split(';').first
        when 'text/html', 'application/xhtml+xml' then :snarf_html
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
            elsif buffer.length > config.limits.stream * 1000
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

        snarfed = nil
        http.request(req) do |res|
          if res.is_a? Net::HTTPRedirection
            return snarfed = snarf_http(URI(res['Location']), depth + 1)
          elsif res.is_a? Net::HTTPSuccess
            return snarfed = snarf_stream(res)
          else
            warn res.inspect
            return
          end
        end
      end
    end

    match /(https?:\/\/[^ >]+)/, use_prefix: false, use_suffix: false, method: :snarf
    def snarf(m, uri)
      uri = URI(uri)
      snarfed = @cache.fetch(uri) do
        begin
          Timeout.timeout(config.timeout) do
            snarf_http(uri)
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
