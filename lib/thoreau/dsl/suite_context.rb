require_relative '../test_suite_data'

module Thoreau
  module DSL

    class SuiteContext

      attr_reader :suite_data
      attr_reader :name
      attr_reader :logger

      def initialize name, data, logger
        @name   = name
        @logger = logger
        @suite_data   = data
      end

      def action(&block)
        logger.debug "adding action block"
        @suite_data.action_block = block
      end

      alias testing action
      alias subject action

      def cases(&block)
        logger.debug "adding cases"
        @suite_data.cases_block = block
      end

      alias test_cases cases

      def appendix(&block)
        logger.debug "adding appendix block"
        @suite_data.appendix_block = block
      end

      def context
        self
      end

    end

  end
end
