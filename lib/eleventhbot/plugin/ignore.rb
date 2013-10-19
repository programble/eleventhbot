module EleventhBot
  class Plugin::Ignore
    include Plugin, Cinch::Plugin

    configru do
      option_array :masks, String
    end

    def initialize(*args)
      super

      ignore_hook = proc do |m|
        if m.user
          !plugin(Ignore).config.masks.any? {|mask| m.user.match(mask) }
        else
          true
        end
      end

      loaded_plugins.each do |plugin|
        plugin.instance_exec do
          @ignore_hook = hook(:pre, method: ignore_hook)
        end
      end
    end

    def unregister
      super
      loaded_plugins.each do |plugin|
        plugin.instance_exec do
          __hooks(:pre).delete(@ignore_hook)
        end
      end
    end

    command :ignores, /ignores/,
      'ignores: List ignored masks',
      group: :admin
    def ignores(m)
      m.reply(config.masks.join(', '), true)
    end

    command :ignore, /ignore (\S+)/,
      'ignore {mask}: Ignore commands from users matching a mask',
      group: :admin
    def ignore(m, mask)
      return m.reply('Mask already ignored', true) if config.masks.include? mask
      config.masks << mask
      m.reply('Mask ignored', true)
    end

    command :unignore, /unignore (\S+)/,
      'unignore {mask}: Stop ignoring commands from users matching a mask',
      group: :admin
    def unignore(m, mask)
      return m.reply('Mask not ignored', true) unless config.masks.include? mask
      config.masks.delete(mask)
      m.reply('Mask unignored', true)
    end
  end
end
