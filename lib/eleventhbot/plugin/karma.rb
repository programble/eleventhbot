module EleventhBot
  class Plugin::Karma
    include Plugin, Cinch::Plugin

    match /^(\S+)(\+\+|--)/, use_prefix: false, method: :incdec
    def incdec(m, target, op)
      target.downcase!
      redis.hincrby(:karma, target, (op == '++') ? 1 : -1)
    end

    command :karma, /karma(?: (\S+))?/,
      'karma [target]: Show how much karma something has'
    def karma(m, target)
      target ||= m.user.nick
      target.downcase!
      m.reply("#{target} has #{redis.hget(:karma, target) || 0} karma")
    end
  end
end
