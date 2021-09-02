require_relative '../test_suite_data'

module Thoreau
  module DSL

    class SuiteContext

      attr_reader :data
      attr_reader :name
      attr_reader :logger
      attr_reader :setups

      def initialize name, data, logger
        @name   = name
        @logger = logger
        @data   = data
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
        @data.cases_block = block
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
