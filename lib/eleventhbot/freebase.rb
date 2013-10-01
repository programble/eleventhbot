require 'open-uri'
require 'json'

module EleventhBot
  class Freebase
    include Plugin, Cinch::Plugin

    BASE_URL = 'https://www.googleapis.com/freebase/v1/'

    configru do
      option :key, String, ''
    end

    def api(req, params = {})
      params[:key] = config['key'] unless config['key'].empty?
      url = BASE_URL + req + ?? + params.map {|k, v| "#{k}=#{URI.escape(v)}" }.join(?&)
      open(url) do |res|
        JSON.parse(res.read)
      end
    end

    def details(topic)
      details = api('topic' + topic['mid'], filter: 'suggest')
      s = String.new
      s << topic['name']
      s << ', the ' << topic['notable']['name'] if topic['notable']
      s << ': '
      s << details['property']['/common/topic/article']['values'].first['text'] if details['property']['/common/topic/article']
      s << ' <http://freebase.com' << topic['mid'] << '>'
    end

    command :info, /info(?: (.+))?/,
      'info [query]: Retrieve information from Freebase'
    def info(m, query)
      if query
        @search = api('search', query: query)
        return m.reply(@search['status'], true) unless @search['status'] == '200 OK'
        return m.reply('No results', true) if @search['hits'].zero?
      else
        return m.reply('No query provided', true) unless @search
        return m.reply('No more results', true) if @search['result'].empty?
      end

      s = @search['result'].shift(2).map {|r| details(r) }.join(' | ')
      s << " (#{@search['hits'] -= 2} more results)" if @search['hits'] > 2
      m.reply(s)
    rescue OpenURI::HTTPError => e
      return m.reply(e, true)
    end
  end
end
