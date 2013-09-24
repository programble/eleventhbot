module EleventhBot
  module Plugin
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
  end
end
