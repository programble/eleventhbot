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
      'My random number generator really like',
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
  end
end
