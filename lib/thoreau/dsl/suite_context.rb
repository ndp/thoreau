module Thoreau
  module DSL
    class TestSuiteData
      attr_accessor :action_block
      attr_accessor :cases
      attr_accessor :appendix_block
      attr_accessor :groups

      def initialize
        @groups = []
      end
    end

    class SuiteContext

      attr_reader :data
      attr_reader :name
      attr_reader :logger
      attr_reader :setups

      def initialize name, logger
        @name   = name
        @logger = logger
        @data   = TestSuiteData.new
        @setups = {}
      end

      def action(&block)
        logger.debug "adding action block"
        @data.action_block = block
      end

      alias testing action
      alias subject action

      def cases(&block)
        logger.debug "adding cases"
        @data.cases = block
      end

      alias test_cases cases

      def appendix(&block)
        logger.debug "adding appendix block"
        @data.appendix_block = block
      end

      def context
        self
      end

    end

  end
end
