require 'socket'
require 'ipaddress'

module EleventhBot
  class Network
    include Plugin, Cinch::Plugin

    command :host, /host (.+)/,
      'host [hostname or IP]: Get IP addresses or reverse DNS for the given query'
    def host(m, name)
      if IPAddress.valid? name
        m.reply Socket.gethostbyaddr(name.split('.').map(&:to_i).pack("CCCC"))[0]
      else
        m.reply Socket.getaddrinfo(name, nil).map { |f| f[2] }.uniq.join(', ')
      end
    end
  end
end
