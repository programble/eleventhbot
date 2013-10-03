require 'cgi'
require 'net/http'
require 'timeout'

module EleventhBot
  class Snarf
    include Plugin, Cinch::Plugin

    configru do
      option_group :limits do
        option :timeout, Fixnum, 3
        option :redirects, Fixnum, 10
        option :stream, Fixnum, 512
      end

      option :useragent, String, 'Mozilla/5.0 (X11; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/24.0'
    end

    # TODO: TTL cache

    TITLE_REGEXP = /<title>(.+)<\/title>/i
    def snarf_html(buffer)
      if match = TITLE_REGEXP.match(buffer)
        '"' + CGI.unescape_html(match[1].gsub(/\s+/, ' ')) + '"'
      end
    end

    SNARF_METHODS = {
      'text/html' => :snarf_html,
      'application/xhtml+xml' => :snarf_html
    }
    def snarf_stream(res)
      method = SNARF_METHODS[res['Content-type'].split(?;).first]
      unless method
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
        # We just ignore it
        # It is the reason for that catch-throw mess up there
      end

      return snarfed
    end

    match /(https?:\/\/\S+)/, use_prefix: false, use_suffix: false, method: :snarf
    def snarf(m, uri)
      uri = URI(uri)
      Timeout.timeout(config.limits.timeout) do
        config.limits.redirects.times do
          Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
            req = Net::HTTP::Get.new(uri)
            req['User-agent'] = config.useragent

            http.request(req) do |res|
              if res.is_a? Net::HTTPRedirection
                uri = URI(res['Location'])
                next
              end
              return warn(res.inspect) unless res.is_a? Net::HTTPSuccess

              # TODO: Generate a short URL
              snarfed = snarf_stream(res)

              m.reply(snarfed) if snarfed
              warn 'no match' unless snarfed
              return
            end # request
          end # http
        end
        warn 'redirect limit'
      end
      warn 'timeout'
    end
  end
end
