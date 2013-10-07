require 'ipaddr'
require 'resolv'

module EleventhBot
  class Network
    include Plugin, Cinch::Plugin

    def ip? ip
      !!IPAddr.new(ip) rescue false
    end

    command :host, /host (\S+)/,
      'host {hostname or IP}: Get IP addresses or reverse DNS for the given query'
    def host(m, name)
      if ip? name
        m.reply(Resolv.getnames(name).join(', '), true)
      else
        m.reply(Resolv.getaddresses(name).join(', '), true)
      end
    end
  end
end
