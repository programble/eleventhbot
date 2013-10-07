require 'unicode_utils'

module EleventhBot
  class Unicode
    include Plugin, Cinch::Plugin

    configru do
      option :find_limit, Fixnum, 10
    end

    command :charname, /charname (.)/,
      'charname [unicode character]: Get unicode name for the character'
    def charname(m, c)
      m.reply UnicodeUtils.sid(c).downcase, true
    end

    command :chartype, /chartype (.)/,
      'chartype [unicode character]: Get unicode character type'
    def chartype(m, c)
      m.reply UnicodeUtils.general_category(c).to_s.downcase.gsub('_', ' '), true
    end

    command :charinfo, /charinfo (.)/,
      'charinfo [unicode character]: Get unicode codepoint, name, and utf8 representation'
    def charinfo(m, c)
      cp = UnicodeUtils::Codepoint.new(c.codepoints.first)
      utf8 = cp.hexbytes.delete(",").upcase
      m.reply "#{cp.uplus} UTF-8:#{utf8} \"#{cp}\" #{cp.name}", true
    end

    command :findchar, /findchar (.+)/,
      'findchar [search words]: Find unicode characters by name'
    def findchar(m, words)
      word_regexps = words.split.map {|word| /\b#{Regexp.escape(word)}\b/i }

      codepoints = UnicodeUtils::Codepoint::RANGE.select do |cp|
        char_name = UnicodeUtils.char_name(cp)
        word_regexps.all? {|word| word =~ char_name }
      end

      len = codepoints.length

      descriptions = codepoints.take(config.find_limit).map do |cp|
        cp = UnicodeUtils::Codepoint.new(cp)
        "#{cp} (#{cp.name.downcase})"
      end

      output = descriptions.join(' ')

      if len > config.find_limit
        output << " ... #{len - config.find_limit} more not shown."
      end

      if len > 0
        m.reply output, true
      else
        m.reply "No matches.", true
      end
    end
  end
end
