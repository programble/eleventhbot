require 'pstore'

module EleventhBot
  class Plugin::Karma
    include Plugin, Cinch::Plugin

    configru do
      option :pstore, String, 'karma.pstore'
    end

    def initialize(*args)
      super
      @pstore = PStore.new(config.pstore)
    end

    match /^(\S+)(\+\+|--)/, use_prefix: false, method: :incdec
    def incdec(m, target, op)
      target.downcase!
      @pstore.transaction do
        @pstore[target] ||= 0
        @pstore[target] += (op == '++') ? 1 : -1
      end
    end

    command :karma, /karma(?: (\S+))?/,
      'karma [target]: Show how much karma something has'
    def karma(m, target)
      target ||= m.user.nick
      target.downcase!
      @pstore.transaction(true) do
        m.reply("#{target} has #{@pstore[target] || 0} karma")
      end
    end
  end
end
