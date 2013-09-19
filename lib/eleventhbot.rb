module EleventhBot
  module Plugin
    module ClassMethods
      attr_reader :configru_group, :configru_block

      def configru(group, &block)
        @configru_group = group
        @configru_block = block
      end
    end

    def self.included(by)
      by.extend ClassMethods
    end
  end
end
