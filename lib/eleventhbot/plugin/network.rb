require 'ipaddr'
require 'resolv'

module EleventhBot
  class Plugin::Network
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
        path = [name]
        Resolv::DNS.open do |dns|
          while cname = dns.getresources(path.last, Resolv::DNS::Resource::IN::CNAME).first
            break if path.include? cname.name
            path << cname.name
          end
          aaaa = dns.getresources(path.last, Resolv::DNS::Resource::IN::AAAA)
          a = dns.getresources(path.last, Resolv::DNS::Resource::IN::A)
          path << (aaaa + a).map(&:address).join(', ') unless aaaa.empty? && a.empty?
        end
        path << '' if path.length == 1
        m.reply(path.join(' -> '), true)
      end
    end

    command :dns, /dns (\S+)(?: (\S+))?/,
      'dns {name} [typeclass]: Look up typeclass DNS resources of name'
    def dns(m, name, typeclass)
      typeclass = typeclass ? typeclass.upcase : 'ANY'
      return unless Resolv::DNS::Resource::IN.const_defined? typeclass
      typeclass = Resolv::DNS::Resource::IN.const_get(typeclass)

      Resolv::DNS.open do |dns|
        resources = dns.getresources(name, typeclass).map do |res|
          s = [res.ttl, 'IN', res.class.name.split(':').last]
          case res
          when Resolv::DNS::Resource::IN::A, Resolv::DNS::Resource::IN::AAAA
            s << res.address
          when Resolv::DNS::Resource::IN::CNAME, Resolv::DNS::Resource::IN::NS
            s << res.name
          when Resolv::DNS::Resource::IN::MX
            s << res.preference << res.exchange
          when Resolv::DNS::Resource::IN::TXT
            s.concat(res.strings)
          else
            next
          end
          s.join(' ')
        end
        m.reply(resources.compact[0..14].join(', '), true)
      end
    end
  end
end
