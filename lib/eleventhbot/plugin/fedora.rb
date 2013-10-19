require 'pkgwat'
require 'nokogiri'

module EleventhBot
  class Plugin::Fedora
    include Plugin, Cinch::Plugin

    def get_version(pkg)
      x = Pkgwat.get_releases pkg

      # This works around this bug with the Fedora Packages API:
      # https://github.com/fedora-infra/fedora-packages/issues/24
      x.map do |v|
        if v['stable_version'].include? '<a'
          v['stable_version'] = Nokogiri::HTML.parse(v['stable_version']).search('a')[0].text
        end

        if v['testing_version'].include? '<a'
          v['testing_version'] = Nokogiri::HTML.parse(v['testing_version']).search('a')[0].text
        end

        v
      end
    end

    command :pkgwat, /pkgwat (.+)/,
      'pkgwat {package}: Get version numbers for Fedora packages'
    def pkgwat(m, pkg)
      v = get_version(pkg)
      m.reply v.map { |f| "#{Format(:bold, f['release'])}: s: #{f['stable_version']}, t: #{f['testing_version']}" }.join(', ')
    end
  end
end
