module EleventhBot
  module Plugin
    module ClassMethods
      attr_reader :configru_group, :configru_block

      def configru(group, &block)
        @configru_group = group
        @configru_block = block
      end
    end

    @list = Array.new

    def self.included(by)
      by.extend ClassMethods
      @list << by
    end

    def self.list
      @list
    end
  end
end
