module EleventhBot
  module Plugin
    @list = Array.new

    def self.included(by)
      by.extend ClassMethods
      @list << by
      by.instance_exec do
        @help_topics = Hash.new
      end
    end

    def self.list
      @list
    end

    module ClassMethods
      attr_reader :configru_block, :help_topics

      def configru(&block)
        @configru_block = block
      end

      def help_topic(topic, help)
        @help_topics[topic.to_s] = help
      end

      def command(name, pattern, helps, options = {})
        options[:method] ||= name
        help_topic(name, helps)
        match(pattern, options)
      end
    end

    # Methods for interacting with other plugins

    def loaded_plugins
      @bot.config.plugins.plugins.select {|p| p.include? Plugin }
    end

    def loaded_plugin(name)
      loaded_plugins.find {|p| p.plugin_name == name }
    end

    def plugins
      @bot.plugins.select {|p| p.is_a? Plugin }
    end

    def plugin(name)
      if name.is_a? Class
        plugins.find {|p| p.is_a? name }
      else
        plugins.find {|p| p.class.plugin_name == name }
      end
    end
  end
end
