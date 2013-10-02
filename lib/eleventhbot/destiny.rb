module EleventhBot
  class Destiny
    include Plugin, Cinch::Plugin

    PHRASES = [
      "I'd go with",
      "Isn't it obvious?",
      'All signs point to',
      'Chooser schoses',
      'Computer magic points to',
      'Consider',
      'Eenie meenie miney',
      'How about',
      'I choose',
      'I chose',
      'Initial thought:',
      'My random number generator really likes',
      'PRNG says',
      'Perhaps',
      'Simon says',
      'The only acceptable answer is',
      'Try',
      'Why not'
    ]

    command :destiny, /(?:destiny|choose)(?: (.+))?/,
      'destiny [choices]: Randomly choose an item from a list of choices, or between yes and no'
    def destiny(m, choices)
      choice = (choices ? choices.split(choices[?,] || $;).map(&:strip) : %w[yes no]).sample
      m.reply("#{PHRASES.sample} #{choice}", true)
    end

    command :coin, /(?:coin|flip)+/,
      'coin: Flip a coin'
    def coin(m)
      m.reply(%w[Heads Tails].sample, true)
    end

    command :roll, /(?:dice|roll)(?: (\d+)d(\d+))?/,
      'roll [ndm]: Roll n m-sided dice'
    match /(\d+)d(\d+)/, method: :roll
    def roll(m, num, sides)
      num = num ? num.to_i : 2
      sides = sides ? sides.to_i : 6
      return if num > 50 || sides > 100
      rolls = Array.new(num) { rand(1..sides) }
      if rolls.length > 1
        m.reply("#{rolls.join(' + ')} = #{rolls.reduce(:+)}", true)
      else
        m.reply(rolls.first, true)
      end
    end

    DECK = '♠♥♦♣'.chars.flat_map {|s| %w[A 2 3 4 5 6 7 8 9 10 J Q K].map {|v| s + v } }

    command :draw, /draw(?: (\d+))?/,
      'draw [num]: Draw cards from a deck'
    def draw(m, n)
      n = n ? n.to_i : 5
      return if n > 52
      m.reply(DECK.sample(n).join(' '), true)
    end
  end
end
