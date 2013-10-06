require 'socket'

module EleventhBot
  class Network
    include Plugin, Cinch::Plugin

    Socket.do_not_reverse_lookup = true

    command :host, /host (.+)/,
      'host [hostname or IP]: Get IP addresses or reverse DNS for the given query'
    def host(m, name)
      m.reply Socket.getaddrinfo(name, nil).map { |f| f[2] }.uniq.join(', ')
    end
  end
end
