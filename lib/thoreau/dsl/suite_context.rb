require_relative '../test_suite_data'

module Thoreau
  module DSL

    class SuiteContext

      include Thoreau::Logging

      attr_reader :suite_data
      attr_reader :name

      def initialize name, data
        @name   = name
        @suite_data   = data
      end

      def action(&block)
        logger.debug "Adding action block"
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
